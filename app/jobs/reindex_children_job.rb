class ReindexChildrenJob < Hyrax::ApplicationJob
  def perform(collection_id)
    ActiveFedora::Base.where("ancestor_collection_ids_tesim: '#{collection_id}' AND has_model_ssim: Work")
                      .each do |work|
      work.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      work.update_index
    end
  end
end
