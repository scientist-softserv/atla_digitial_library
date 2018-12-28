module Hyrax
  # Renders the Help page, terms of use, messages about exporting to Zotero and Mendeley
  class StaticController < ApplicationController
    layout 'homepage'

    def zotero
      super
    end

    def mendeley
      super
    end

    def institutions
      render 'static/institutions.html.erb'
    end
  end
end
