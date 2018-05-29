class HarvestWorkJob < ActiveJob::Base
  queue_as :default

  def perform(harvester_id, identifier, harvest_run_id)
    # pull the harvester from db
    h = Harvester.find harvester_id

    # create an importer
    importer = h.importer

    if importer.get_record identifier
      Rails.logger.info "successfully harvested #{identifier}"
    else
      Rails.logger.error "unable to harvest #{identifier}"
    end

    harvest_run = HarvestRun.find(harvest_run_id)
    harvest_run.processed += 1
    harvest_run.save
  end
end
