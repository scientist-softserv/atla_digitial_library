# This has been moved over from Hyrax to allow for the addition of the "slug" field.
# Lines/blocks that are changed by this move are marked with: UPGRADE NOTE.
module Hyrax
  class CollectionsController < ApplicationController
    include CollectionsControllerBehavior
    include BreadcrumbsForCollections
    with_themed_layout :decide_layout
    load_and_authorize_resource except: [:index, :show, :create], instance_name: :collection
    prepend_before_action :slugitout, only: [:show]

    # Renders a JSON response with a list of files in this collection
    # This is used by the edit form to populate the thumbnail_id dropdown
    def files
      result = form.select_files.map do |label, id|
        { id: id, text: label }
      end
      render json: result
    end

    # UPGRADE NOTE: start of block.
    # This is actually overriding app/controllers/concerns/hyrax/collections_controller_behavior.rb in the hyrax gem.
    def show
      # Sets a cookie to be used for dynamically populating breadcrumbs
      cookies[:_atla_last_collection_visited_id] = @curation_concern.id
      presenter
      query_collection_members
    end
    # UPGRADE NOTE: end of block

    private

    def form
      @form ||= form_class.new(@collection, current_ability, repository)
    end

    def decide_layout
      layout = case action_name
              when 'show'
                '1_column'
              else
                'dashboard'
              end
      File.join(theme, layout)
    end

    def slugitout
      if params[:id]
        @curation_concern = Collection.where(slug_sim: params[:id]).first || Collection.find(params[:id])
        # TODO: This is about as hacky as you can get and should be fixed.
        # The problem is that further down the stack,
        # where permissions are searched for and matched against
        # the current user, it is looking at params[:id],
        # which it expects to be the ID of the Collection instead
        # of the instance method's (@curation_concern) ID.
        # Because we are overriding the default behavior here
        # to begin with it makes more sense (for now)
        # to give the rest of the stack what it expects.
        # The most ideal solution would have methods that require
        # the collection id to have it passed as a function argument.
        params[:id] = @curation_concern.id
      end
    end
  end
end
