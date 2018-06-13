require 'progress_bar'

namespace :import do
  task :fix_images => :environment do
    c = Collection.find '8w32rb49z'
    h = Harvester.last
    @bar = ProgressBar.new(c.works.count)
    c.works.each do |work|
      @bar.increment!
      w.file_sets.each do |f|
        f.destroy if f.files.first.persisted_size < 100
      end
      if w.reload.file_sets.size < 1
        r = h.importer.get_record(w.source.first)
      end
    end
  end
end
