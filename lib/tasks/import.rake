require 'progress_bar'

namespace :import do
  task :fix_images => :environment do
    c = Collection.find '8w32rb49z'
    h = Harvester.last
    @bar = ProgressBar.new(c.works.count)
    c.works.each do |work|
      retries = 0
      @bar.increment!
      begin
        w.file_sets.each do |f|
          f.destroy if f.files.try(:first).try(:persisted_size).to_i < 100
        end
        if w.reload.file_sets.size < 1
          r = h.importer.get_record(w.source.first)
        end
      rescue Faraday::TimeoutError
        retry if (retires += 1) <= 3
      end
    end
  end

  task :fix_admin_sets => :environment do
    # Dr. William x
    #Robert E. Naylor x
    #Bowld 
    #Charles Koller x
    #James McKinney x
    #1940s Chapel Services x
    #1950s x
    #1960s x
    #1970s x
    #1980s x
    #1990s x
    [ 'br86b886g', 'hq37vt81q', 'q237hz48p', 'x633f623v', '7w62ff82b', '6682x905m', '6q182r61g', 'd504rr272', 'j098zh332', '028712200', 'ww72bh820' ].each do |c_id|
      c = Collection.find c_id
      @bar = ProgressBar.new(c.works.count)
      c.works.each do |work|
        retries = 0
        @bar.increment!
        begin
          w.admin_set_id = "admin_set/default"
          w.save
        rescue Faraday::TimeoutError
          retry if (retries += 1) <= 3
        end
      end
    end
  end
end
