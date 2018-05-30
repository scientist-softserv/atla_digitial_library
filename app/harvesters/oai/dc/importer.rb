class OAI::DC::Importer < OAI::Base::Importer
  def work_factory
    @work_factory ||= OAI::DC::WorkFactory.new(admin_set_id, user)
  end

  def record_parser_class
    OAI::DC::RecordParser
  end
end
