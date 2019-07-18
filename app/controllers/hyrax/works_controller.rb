# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  # Generated controller for Work
  class WorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
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
    #  TODO: create new method in Work model that doesn't return ALL Collections
    #        and dynamically selects which Collections to show (maybe using cookies?)
    def add_breadcrumb_to_show_page
      add_breadcrumb I18n.t('hyrax.controls.home'), hyrax.root_path
      dynamic_collection_breadcrumbs
      add_breadcrumb_for_action
    end

    def dynamic_collection_breadcrumbs
      @last_collection_visited_id = cookies[:_atla_last_collection_visited_id]
      if @last_collection_visited_id.present? && presenter.member_of_collection_ids.join(',').match?(@last_collection_visited_id) && presenter.ancestor_relationships.present?
        presenter.ancestor_relationships.each do |ar|
          if ar.match?(@last_collection_visited_id)
            parse_ancestor_relationship(ar)
          end
        end
      elsif presenter.ancestor_relationships.present?
        default_collection_ids = presenter.ancestor_relationships.first
        parse_ancestor_relationship(default_collection_ids)
      else
        collection = Collection.find(presenter.member_of_collection_ids.first)
        add_breadcrumb collection.to_s, hyrax.collection_path(collection)
      end
    end

    def parse_ancestor_relationship(collection_ids)
      collection_ids.split(':').each do |c_id|
        collection = Collection.find(c_id)
        add_breadcrumb collection.to_s, hyrax.collection_path(collection)
      end
    end
  end
end
