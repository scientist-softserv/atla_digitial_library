# coding: utf-8
namespace :atla do
  desc 'reset file_sets visibility to open for items in the Unitarian Universalist Women’s Federation Records collection'
  task reset_file_set_visibility: [:environment] do
    c = Collection.find("vh53x9719")
    raise 'collection not found' unless c.present?
    works = ActiveFedora::Base.where(member_of_collection_ids_ssim: c.id, has_model_ssim: ['Work'])
    progress = ProgressBar.create(format: "%t %c of %C %a %B %p%%", total: works).count)
    errors = []
    begin
      works.each do |work|
      filesets = work.filesets
      filesets.each do |fs|
        # update visibility to "open"
        fs.visibility = 'open'
        fs.save!
      end
    rescue => e
      errors << [file, e]
    end
    progress.increment
  end
  if errors.present?
    $stderr.puts "-- ERRORS REPORTED"
    $stderr.puts "#{work.id} - #{e.message}\n#{e.backtrace[0..6]}"
  end
end
