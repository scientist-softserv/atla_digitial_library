module SufiaHelper
  include ::BlacklightHelper
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior

  def license_text(options)
    service = CurationConcerns::LicenseService.new
    options[:value].map { |right| service.label(right) }.to_sentence.html_safe
  end
end
