class UpdateStatisticalDataJob < Hyrax::ApplicationJob
  queue_as :update_statistical_data

  def perform
    service = StatisticalDataService.new

    service.update_home_page
    service.update_institutions_page

    self.class.set(wait_until: 1.week.from_now.beginning_of_day).perform_later
  rescue
    false
  end
end
