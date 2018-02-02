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
end
