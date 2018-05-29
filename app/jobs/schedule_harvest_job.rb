class ScheduleHarvestJob < ActiveJob::Base
  queue_as :default

  def perform(harvester_id, next_harvest_at)
    h = Harvester.find harvester_id

    HarvestSetJob.set(wait_until: Time.parse(next_harvest_at)).perform_later(h.id)
  end
end
