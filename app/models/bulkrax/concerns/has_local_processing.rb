module Bulkrax::Concerns::HasLocalProcessing
  
  def contributing_institution
    parser.parser_fields['institution_name']
  end

  def add_local
    self.parsed_metadata['contributing_institution'] ||= [contributing_institution].compact
  end

  def self.matcher_class
    Bulkrax::AtlaMatcher
  end
end
