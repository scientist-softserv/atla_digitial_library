# NOTE(dewey4iv @ 06/18/20): Hyrax Override: fotmats aren't quite what Atla wants.
# Changed to match: https://gitlab.com/notch8/atla_digital_library/-/issues/285#note_363126537

# frozen_string_literal: true
module Hyrax
  module CitationsBehaviors
    module Formatters
      class BaseFormatter
        include Hyrax::CitationsBehaviors::CommonBehavior
        include Hyrax::CitationsBehaviors::NameBehavior

        attr_reader :view_context

        def initialize(view_context)
          @view_context = view_context
        end

        # NOTE(dewey4iv): Hyrax Override: Adds new functionality for citations
        def add_retrieved_from
          ' Retrieved from the Atla Digital Library'
        end

        def add_link_to_original(work)
          ", #{work.identifier.find { |d| d =~ /http/ }}."
        end
        # end
      end

      autoload :ApaFormatter, 'hyrax/citations_behaviors/formatters/apa_formatter'
      autoload :ChicagoFormatter, 'hyrax/citations_behaviors/formatters/chicago_formatter'
      autoload :MlaFormatter, 'hyrax/citations_behaviors/formatters/mla_formatter'
      autoload :OpenUrlFormatter, 'hyrax/citations_behaviors/formatters/open_url_formatter'
    end
  end
end
