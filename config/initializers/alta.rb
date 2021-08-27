Rails.application.config.to_prepare do
  Qa::Authorities::Local::FileBasedAuthority.prepend ::PrependFileBasedAuthority

  Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")).sort.each do |c|
    Rails.configuration.cache_classes ? require(c) : load(c)
  end
end
