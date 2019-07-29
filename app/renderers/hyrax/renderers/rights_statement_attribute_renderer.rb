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
          new_value = value.gsub(URI.regexp, '<a target="_blank" href="\0">\0</a>')
          sentenses = new_value.split('.')
          sentenses[0] = "<strong>#{sentenses[0]}</strong>"
          new_value = sentenses.join('.')
          ERB::Util.h(new_value.html_safe)
        else
          label
        end
      end
    end
  end
end
