# Generated via
#  `rails generate hyrax:work Work`
class WorkIndexer < Hyrax::WorkIndexer
  include ActionView::Helpers::SanitizeHelper # For strip_tags support
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
      if object.transcript_url
        begin
          transcript = open(object.transcript_url).read
          # Solr max length is 32766
          transcript = strip_tags(transcript.gsub("&nbsp;", " ").gsub(">", "> ")).strip[0..32760]
          solr_doc['transcript_tesim'] = [transcript]
        rescue => e
          Raven.capture_exception(e)
        end
      end
    end
  end

end
