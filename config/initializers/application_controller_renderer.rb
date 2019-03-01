# Be sure to restart your server when you modify this file.

ActiveSupport::Reloader.to_prepare do
  Hyrax::CurationConcern.actor_factory.delete Hyrax::Actors::TransactionalRequest
#   ApplicationController.renderer.defaults.merge!(
#     http_host: 'example.org',
#     https: false
#   )
end
