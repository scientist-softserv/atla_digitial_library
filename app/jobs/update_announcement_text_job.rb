require 'rake'

Rake::Task.clear
AtlaDigitalLibrary::Application.load_tasks

class UpdateAnnouncementTextJob < Hyrax::ApplicationJob
  queue_as :update_announcement_text

  def perform
    begin
      Rake::Task['atla:update_announcement_text'].invoke

      # self.class.set(wait_until: tomorrow.midnight).perform_later
      self.class.set(wait_until: 2.minutes.from_now).perform_later
    rescue
      return false
    end
  end
end
