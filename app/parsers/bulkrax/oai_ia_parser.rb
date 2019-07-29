module Bulkrax
  # Parser for the Internet Archive OAI-PMH Endpoint
  class OaiIaParser < OaiDcParser
    def entry_class
      OaiIaEntry
    end

  end
end
