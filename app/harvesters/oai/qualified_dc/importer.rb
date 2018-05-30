class OAI::QualifiedDC::Importer < OAI::Base::Importer
  def work_factory
    @work_factory ||= OAI::QualifiedDC::WorkFactory.new(admin_set_id, user)
  end

  def record_parser_class
    OAI::QualifiedDC::RecordParser
  end
end
