module ApplicationHelper
  def faceted_search_path(field, value)
    Rails.application
         .routes
         .url_helpers
         .search_catalog_path(
           :"f[#{field}][]" => ERB::Util.h(value)
         )
  end

  def solr_search_field(field)
    # ERB::Util.h(Solrizer.solr_name(options.fetch(:search_field, field), :facetable, type: :string))
  end
  ##
  # Render the thumbnail, if available, for a document and
  # link it to the document record.
  #
  # @param [SolrDocument] document
  # @param [Hash] image_options to pass to the image tag
  # @param [Hash] url_options to pass to #link_to_document
  # @return [String]
  def render_full_image_tag(document, image_options = {}, url_options = {})
    value = if blacklight_config.view_config(document_index_view_type).thumbnail_method
      send(blacklight_config.view_config(document_index_view_type).thumbnail_method, document, image_options)
    elsif blacklight_config.view_config(document_index_view_type).thumbnail_field
      url = thumbnail_url(document).gsub('?file=thumbnail', '')

      image_tag url, image_options if url.present?
    end

    if value
      if url_options == false || url_options[:suppress_link]
        value
      else
        link_to_document document, value, url_options
      end
    end
  end
end
