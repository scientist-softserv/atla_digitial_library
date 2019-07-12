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
      presenter.ancestor_collections.each do |c|
        add_breadcrumb "#{c.title.first}", hyrax.collection_path(c)
      end
      add_breadcrumb_for_action
    end
  end
end
