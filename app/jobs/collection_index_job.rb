class CollectionIndexJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    collection = Collection.find(id)

    ActiveFedora::SolrService.add(collection.to_solr, softCommit: true)
  end

  def self.exists?(id)
    Delayed::Job.where("locked_at IS NULL AND handler LIKE ? AND handler LIKE ?", "%job_class: CollectionIndexJob%", "%arguments:\n  - #{id}%").count > 0
  end
end
