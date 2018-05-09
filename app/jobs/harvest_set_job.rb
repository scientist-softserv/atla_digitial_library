class HarvestSetJob < ActiveJob::Base
  queue_as :default

  def perform(harvester_id)
    h = Harvester.find harvester_id

    start = Time.current

    # create an importer based on harvester
    importer = OAI::DC::Importer.new(h.base_url, h.thumbnail_url, h.right_statement, h.institution_name, User.find(h.user_id), h.admin_set_id, {})

    limit = h.limit

    importer.list_identifiers({set: h.external_set_id}).each do |identifier|
      HarvestWorkJob.perform_later(h.id, identifier.identifier)

      limit -= 1 if !limit.nil?
      break if !limit.nil? and limit == 0
    end

    # saving the time the job started so we don't end up with time staggering
    h.last_harvested_at = start
    h.save

    if h.schedulable?
      ScheduleHarvestJob.perform_later(h.id, "#{h.next_harvest_at}")
    end
  end
end
