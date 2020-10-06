module Hyrax
  module Renderers
    class ExternalLinkAttributeRenderer < AttributeRenderer
      private

      def li_value(value)
        Rinku.auto_link(value, :all, 'target="_blank"') do |link|
          "#{link}&nbsp;<span class='glyphicon glyphicon-new-window'></span>"
        end
      end
    end
  end
end
