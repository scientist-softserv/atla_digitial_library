class CollectionIndexJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    collection = Collection.find(id)

    ActiveFedora::SolrService.add(collection.to_solr, softCommit: true)
  end
end
