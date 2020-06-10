namespace :atla do
  desc 'recalculates the announcement text'
  task update_announcement_text: [:environment] do
    service = StatisticalDataService.new
    service.update_home_page
  end

  desc 'updates the work counts on the institutions page'
  task update_institutions_page: [:environment] do
    service = StatisticalDataService.new
    service.update_institutions_page
  end
end
