ActiveFedora::Fedora.class_eval do
  def ntriples_connection
    authorized_connection.tap { |conn| conn.headers['Accept'] = 'application/n-triples' }
  end

  def build_ntriples_connection
    ActiveFedora::InitializingConnection.new(ActiveFedora::CachingConnection.new(ntriples_connection, omit_ldpr_interaction_model: true), root_resource_path)
  end
end

ActiveFedora::Indexing::DescendantFetcher.class_eval do
  private
  def rdf_resource
    @rdf_resource ||= Ldp::Resource::RdfSource.new(ActiveFedora.fedora.build_ntriples_connection, uri)
  end
end

# ## Catch missing nodes and skip them
# Ldp::Resource::RdfSource.class_eval do
#   def graph
#     @graph ||= begin
#                  if subject.nil?
#                    build_empty_graph
#                  else
#                    filtered_graph(response_graph)
#                  end
#                rescue Ldp::NotFound, Ldp::HttpError
#                  # This is an optimization that lets us avoid doing HEAD + GET
#                  # when the object exists. We just need to handle the 404 case
#                  build_empty_graph
#                end
#   end
# end
