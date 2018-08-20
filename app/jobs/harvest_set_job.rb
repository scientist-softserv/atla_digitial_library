class HarvestSetJob < ActiveJob::Base
  queue_as :default

  def perform(harvester_id, only_updates_since_last_harvest=false, use_harvester_name=true)
    h = Harvester.find harvester_id

    start = Time.current

    # create an importer based on harvester
    importer = h.importer
    collections = [] # used for delete clean up

    primary_collection = nil

    # create the collections first so that the parallel jobs can access them
    importer.list_sets.each do |set|
      if h.external_set_id == "all" || h.external_set_id == set.spec
        collection = Collection.where(name_code: [set.spec]).first
        collection ||= Collection.create(title: [use_harvester_name ? h.name : set.name],
                                         name_code: [set.spec],
                                         institution: [h.institution_name] )
        primary_collection = collection if h.external_set_id == set.spec
      end
    end

    limit = h.limit
    list_identifiers_args = {}
    list_identifiers_args[:set] = h.external_set_id unless h.external_set_id == 'all'
    list_identifiers_args[:from] = h.last_harvested_at if only_updates_since_last_harvest
    harvest_run = h.harvest_runs.create(total: limit)

    seen = {}

    begin
      importer.list_identifiers(list_identifiers_args).full.each_with_index do |identifier, index|
        if !limit.nil? and index >= limit
          break
        elsif identifier.status == "deleted"
          harvest_run.deleted += 1
        else
          seen[identifier.identifier] = true
          HarvestWorkJob.perform_later(h.id, identifier.identifier, harvest_run.id)
          if limit.to_i > 0
            harvest_run.total = limit
          elsif importer.total > 0
            harvest_run.total = importer.total
          else
            harvest_run.total = index + 1
          end
          harvest_run.enqueued = index + 1
        end
        harvest_run.save
      end
    rescue OAI::Exception => e
      if e.code == "noRecordsMatch"
        # continue there were 0 records to update
      else
        raise e
      end
    end

    # saving the time the job started so we don't end up with time staggering
    h.last_harvested_at = start
    h.save

    if primary_collection
      primary_collection.member_ids.each do |id|
        w = Work.find id
        unless seen[w.source[0]]
          if w.in_collections.size > 1
            primary_collection.members.delete w # only removes from primary collection - wants the record, not the id
            primary_collection.save
          else
            w.delete # removes from all collections
          end
        end
      end
    end

    if h.schedulable?
      ScheduleHarvestJob.perform_later(h.id, "#{h.next_harvest_at}")
    end
  end
end
