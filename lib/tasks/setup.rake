require Rails.root.join('lib', 'importers', 'collection_importer')

namespace :setup do
  desc 'Import a cdri metadata xml export'
  task :import_metadata, [:filepath, :user_email] => :environment do |_t, args|
    file_path = args[:filepath]
    user_email = args[:user_email]
    puts "#{file_path} will import metadata as #{user_email}"
    logger = Logger.new(Rails.root.join('log', 'importer.log'), 10, 1_024_000)
    Atla::CollectionImporter.new(file_path, user_email, logger).process
  end

  desc 'Import single collection from metadata xml file'
  task :import_metadata_for_collection, [:filepath, :user_email, :name_code] => :environment do |_t, args|
    file_path = args[:filepath]
    user_email = args[:user_email]
    collection_name_code = args[:name_code]
    puts "#{file_path} will import metadata as #{user_email}"
    logger = Logger.new(Rails.root.join('log', 'importer.log'), 10, 1_024_000)
    puts "Only importing metadata for the collection with the code #{collection_name_code}"
    Atla::CollectionImporter.new(file_path, user_email, logger, collection: collection_name_code).process
  end

  desc 'Import files from dir to exsiting works'
  task :import_files, [:dir, :user_email] => :environment do |_t, args|
    dirs = Dir["#{args[:dir]}/*"]
    user = User.where(email: args[:user_email]).first
    logger = Logger.new(Rails.root.join('log', 'file_importer.log'), 10, 1_024_000)
    dirs.each do |dir|
      image_paths = Dir[dir + '/*']
      match_path = dir.match(/([A-Z0-9]+)/)
      next if match_path.nil?
      name_code = match_path[1]
      collection = Collection.where(name_code: name_code).first
      if collection.blank?
        puts "no collection found for name_code #{name_code}"
        logger.error("no collection found for name_code #{name_code}")
        next
      else
        puts "collection found for name_code #{name_code}"
      end
      works = collection.works
      file_paths_matched = []
      works.each do |work|
        if work.file_sets.present?
          puts "work with id #{work.id} already has a image associated with it"
          next
        end
        file_path = image_paths.detect do |i|
          i =~ Regexp.new(work.file_name.first, true)
        end
        if file_path.blank?
          msg = "no file for work id #{work.id} in dir #{dir}"
          puts msg
          logger.info(msg)
          next
        end
        file_paths_matched << file_path
        begin
          uploaded_file = Sufia::UploadedFile.create(file: File.open(file_path), user: user)
          file_set = FileSet.new
          actor = CurationConcerns::Actors::FileSetActor.new(file_set, user)
          actor.create_metadata(work, visibility: work.visibility) do |file|
            file.permissions_attributes = work.permissions.map(&:to_hash)
          end
          actor.create_content(uploaded_file.file.file)
          uploaded_file.update(file_set_uri: file_set.uri)
          msg = "#{file_path} added to work with id #{work.id}"
          puts msg
        rescue Exception => e
          msg = "#{e}, could not add file at #{file_path}, to #{work.inspect}"
          puts msg
          logger.error(msg)
        end
      end
      puts "files that no work was found for: #{(image_paths - file_paths_matched).join(', ')}"
    end
  end

  desc 'Set visibility of all items to public'
  task :set_everything_public, [] => :environment do
    Collection.all.each do |collection|
      collection.visibility = 'open'
      collection.save
      collection.works.each do |work|
        work.visibility = 'open'
        work.save
        work.file_sets.each do |fs|
          fs.visibility = 'open'
          fs.save
        end
      end
    end
  end

  desc 'Assign all works to a single collection'
  task :assign_all_works_to, [:collection_id] => :environment do |_t, args|
    all_work_ids = Work.all.map(&:id)
    collection = Collection.find(args[:collection_id])
    collection_works_ids = collection.works.map(&:id)
    ids_to_add = (all_work_ids - collection_works_ids)
    puts "adding #{ids_to_add.count} works to collection #{args[:collection_id]}"
    collection.add_members(ids_to_add)
  end
end
