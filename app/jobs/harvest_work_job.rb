class HarvestWorkJob < ActiveJob::Base
  queue_as :default

  def perform(harvester_id, identifier, harvest_run_id)
    # pull the harvester from db
    h = Harvester.find harvester_id

    # create an importer
    importer = OAI::DC::Importer.new(h.base_url, h.thumbnail_url, h.right_statement, h.institution_name, User.find(h.user_id), h.admin_set_id, {})

    if importer.get_record identifier
      puts "successfully harvested #{identifier}"
    else
      puts "unable to harvest #{identifier}"
    end

    harvest_run = HarvestRun.find(harvest_run_id)
    harvest_run.processed += 1
    harvest_run.save
  end
end
