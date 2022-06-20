# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  # Generated controller for Work
  class WorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Adds behaviors for hyrax-iiif_av plugin.
    include Hyrax::IiifAv::ControllerBehavior
    self.curation_concern_type = ::Work

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::WorkPresenter

    ## Overrides Hyrax method to customize how breadcrumbs appear on Work show pages.
    #  Original method found at:
    #  https://github.com/samvera/hyrax/blob/v2.5.1/app/controllers/concerns/hyrax/breadcrumbs_for_works.rb
    def build_breadcrumbs
      return add_breadcrumb_to_show_page if action_name == 'show'
      super
    end

    ## Custom method for Work show pages. Breadcrumbs reflect a
    #  hierarchical structure of which Collections the Work belongs to.
    def add_breadcrumb_to_show_page
      add_breadcrumb I18n.t('hyrax.controls.home'), hyrax.root_path
      dynamic_collection_breadcrumbs
      add_breadcrumb_for_action
      add_back_to_search_crumb
    end

    def dynamic_collection_breadcrumbs
      last_visited = cookies[:_atla_last_collection_visited_id]

      if presenter.ancestor_relationships.present?
        id_str = (last_visited.present? && presenter.ancestor_relationships.detect do |ar|
                    ar.match?(last_visited)
                  end) || presenter.ancestor_relationships.first
        add_ancestor_breadcrumbs(id_str)
      elsif presenter.member_of_collection_ids.present?
        collection = Collection.find(presenter.member_of_collection_ids.first)
        add_breadcrumb collection.to_s, hyrax.collection_path(collection)
      end
    end

    ## Takes in a value with the structure of:
    #  "grandparent_collection_id:parent_collection_id"
    def add_ancestor_breadcrumbs(collection_ids)
      return unless collection_ids.present?

      collection_ids.split(':').each do |c_id|
        collection = Collection.find(c_id)
        add_breadcrumb collection.to_s, hyrax.collection_path(collection)
      end
    end

    def add_back_to_search_crumb
      return unless request.referer&.match?('catalog')
      add_breadcrumb I18n.t('hyrax.bread_crumb.search_results'), request.referer, class: 'back-to-search col-md-3'
    end
  end
end
