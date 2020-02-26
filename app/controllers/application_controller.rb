class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  skip_after_action :discard_flash_if_xhr
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'


  protect_from_forgery with: :exception
  before_action :set_raven_context
  before_action :authenticate_for_staging
  
  private

  def authenticate_for_staging
    if ['staging'].include?(Rails.env) && !request.format.to_s.match('json') && !params[:print] && !request.path.include?('api') && !request.path.include?('pdf')
      authenticate_or_request_with_http_basic do |username, password|
        username == "atla" && password == "atla"
      end
    end
  end

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    if params.respond_to?(:to_unsafe_h)
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    else
      Raven.extra_context(params: params.to_h, url: request.url)
    end
  end

end
