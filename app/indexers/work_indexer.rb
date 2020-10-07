# Generated via
#  `rails generate hyrax:work Work`
class WorkIndexer < Hyrax::WorkIndexer
  # Override the default mete data for the Atla superset
  def rdf_service
    AtlaWorkMetadataIndexer
  end

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
      if object.thumbnail&.video?
        solr_doc['thumbnail_path_ss'] = ActionController::Base.helpers.asset_path('video.png')
      elsif object.thumbnail&.audio?
        solr_doc['thumbnail_path_ss'] = ActionController::Base.helpers.asset_path('audio.png')
      elsif object.thumbnail&.mime_type == 'text/html'
        solr_doc['thumbnail_path_ss'] = ActionController::Base.helpers.asset_path('html.png')
      end
    end
  end

end
