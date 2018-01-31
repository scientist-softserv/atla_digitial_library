require Rails.root.join('lib', 'importers', 'oai_importer')

namespace :import do
  desc 'Import from Princeton Theological Commons'
  task :import_ptc_oia, %i[user_email test] => :environment do |_, args|
    options = {
      url: 'http://commons.ptsem.edu/api/oai-pmh',
      image_url: 'http://commons.ptsem.edu/',
      default_collection_name: 'Princeton Theological Commons Collection',
      user_email: args[:user_email],
      test: args[:test] == 'true',
      name: 'ptsem',
      headers: { from: 'rob@notch8.com' }
    }
    Atla::OaiImporter.new(options).process
  end
end
