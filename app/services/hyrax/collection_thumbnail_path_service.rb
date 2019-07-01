# frozen_string_literal: true
# added default collection image

module Hyrax
  class CollectionThumbnailPathService < Hyrax::ThumbnailPathService
    class << self
      def default_image
        ActionController::Base.helpers.image_path 'atla-collection.png'
      end
    end
  end
end
