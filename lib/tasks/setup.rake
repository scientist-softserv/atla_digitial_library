require Rails.root.join('lib', 'importers', 'collection_importer')

namespace :setup do
  desc 'Import a directory'
  task :import, [:filepath, :user_email] => :environment do |_t, args|
    file_path = args[:filepath]
    user_email = args[:user_email]
    puts "#{file_path} will import metadata as #{user_email}"
    Atla::CollectionImporter.new(file_path, user_email).process
  end
end
