class OAI::PTC::Importer < OAI::Base::Importer
  def work_factory
    @work_factory ||= OAI::PTC::WorkFactory.new(admin_set_id, user)
  end

  def record_parser_class
    OAI::PTC::RecordParser
  end
end
