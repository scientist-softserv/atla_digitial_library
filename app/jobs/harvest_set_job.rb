class HarvestSetJob < ActiveJob::Base
  queue_as :default

  def perform(harvester_id)
    h = Harvester.find harvester_id

    start = Time.current

    # create an importer based on harvester
    importer = h.importer

    # create the collections first so that the parallel jobs can access them
    importer.list_sets.each do |set|
      if h.external_set_id == "all" || h.external_set_id == set.spec
        collection = Collection.where(name_code: [set.spec]).first
        collection ||= Collection.create(title: [set.name],
                                         name_code: [set.spec],
                                         institution: [h.institution_name] )
      end
    end

    limit = h.limit
    harvest_run = h.harvest_runs.create(total: limit)
    importer.list_identifiers({set: h.external_set_id}).full.each_with_index do |identifier, index|
      HarvestWorkJob.perform_later(h.id, identifier.identifier, harvest_run.id)

      if (index + 1) % 25 == 0
        harvest_run.total = importer.total unless limit.to_i > 0
        harvest_run.enqueued = index + 1
        harvest_run.save
      end
      break if !limit.nil? and index >= limit
    end

    # saving the time the job started so we don't end up with time staggering
    h.last_harvested_at = start
    h.save

    if h.schedulable?
      ScheduleHarvestJob.perform_later(h.id, "#{h.next_harvest_at}")
    end
  end
end
