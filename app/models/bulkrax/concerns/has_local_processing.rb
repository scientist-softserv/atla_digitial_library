module Bulkrax::Concerns::HasLocalProcessing

  def contributing_institution
    parser.parser_fields['institution_name']
  end

  def add_local
    # If the contibuting insts is empty or if it only contains empty strings eg. [""]
    if self.parsed_metadata['contributing_institution'].blank? ||
        !self.parsed_metadata['contributing_institution'].detect { |i| i.present? }
      self.parsed_metadata['contributing_institution'] = [contributing_institution].compact
    end
  end

  def self.matcher_class
    Bulkrax::AtlaMatcher
  end
end
