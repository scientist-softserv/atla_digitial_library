namespace :hyrax do
  desc 'Reset database / fedora / solr'
  task :reset => [:environment] do
    require 'active_fedora/cleaner'
    ActiveFedora::Cleaner.clean!
    Hyrax::PermissionTemplateAccess.delete_all
    Hyrax::PermissionTemplate.delete_all
    Delayed::Job.delete_all
    Rake::Task["hyrax:default_collection_types:create"].invoke
    #    Rake::Task["hyrax:default_admin_set:create"].invoke
  end
end
