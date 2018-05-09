class HarvestWorkJob < ActiveJob::Base
  queue_as :default

  def perform(harvester_id, identifier)
    # pull the harvester from db
    h = Harvester.find harvester_id

    # create an importer
    importer = OAI::DC::Importer.new(h.base_url, h.thumbnail_url, h.right_statement, h.institution_name, User.find(h.user_id), h.admin_set_id, {})

    if importer.get_record identifier
      puts "successfully harvested #{identifier}"
    else
      puts "unable to harvest #{identifier}"
    end
  end
end
