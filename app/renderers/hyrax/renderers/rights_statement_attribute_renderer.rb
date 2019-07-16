module Hyrax
  module Renderers
    # This is used by PresentsAttributes to show licenses
    #   e.g.: presenter.attribute_to_html(:rights_statement, render_as: :rights_statement)
    class RightsStatementAttributeRenderer < AttributeRenderer
      private

      ##
      # Special treatment for license/rights.  A URL from the Hyrax gem's config/hyrax.rb is stored in the descMetadata of the
      # curation_concern.  If that URL is valid in form, then it is used as a link.  If it is not valid, it is used as plain text.
      def attribute_value_to_html(value)
        label = RightsStatementLookup.description_for(value)
        if label.blank?
          ERB::Util.h(value.gsub(URI.regexp, '<a href="\0">\0</a>'))
        else
          label
        end
      end
    end
  end
end
