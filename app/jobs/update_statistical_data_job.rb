class UpdateStatisticalDataJob < Hyrax::ApplicationJob
  queue_as :update_statistical_data
  repeat 'every week at 8am' # midnight pst

  def perform
    service = StatisticalDataService.new

    service.update_home_page
    service.update_institutions_page

  rescue
    false
  end
end
