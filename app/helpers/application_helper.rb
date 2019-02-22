module ApplicationHelper
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

  def featured_work_title(work_id)
    Work.find(work_id).title.first
  end
end
