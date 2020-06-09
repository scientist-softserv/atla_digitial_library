namespace :atla do
  desc 'updates the work counts on the institutions page'
  task update_institutions_page: [:environment] do
    service = ContributingInstitutionCounterService.new
    service.run
  end
end
