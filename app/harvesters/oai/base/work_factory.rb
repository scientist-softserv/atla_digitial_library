module OAI::Base
  class WorkFactory
    attr_accessor :admin_set_id

    def initialize(admin_set_id, user)
      @admin_set_id = admin_set_id
      @user = user
      @valid_attrs = Work.new.attributes.keys
    end

    def build(attrs)
      # TODO: this could be smarter: do a check of the attributes
      # and a found work. Ideally, we don't want to re-download an image
      # set the attributes (blindly) and then do an (expensive) update to solr.
      work = existing_or_new_work(attrs['source'])
      verb = work.new_record? ? "created" : "updated"

      if attrs['collection']
        collections = attrs['collection'].map do |collection_title|
          collection = Collection.where(title: collection_title).first
          collection ||= Collection.where(identifier: collection_title).first
          collection ||= Collection.create(title: [collection_title])
        end
      end

      clean_attrs(attrs).each do |key, value|
        next if key == "id"

        work.send("#{key}=", value)
      end

      work.apply_depositor_metadata(@user.user_key) # magic method -- important, leave it alone! (dig)
      work.visibility = 'open' # this still needs to be set because we aren't setting the permission template properly.
      work.admin_set_id = @admin_set_id

      if work.save
        if collections.present?
          collections.each do |collection|
            collection.apply_depositor_metadata(@user.user_key)
            collection.visibility = 'open' # this may need to be changed -- but it is set as open on the work as well
            collection.add_members([work.id])
            collection.save
          end
        end

        add_image(attrs['thumbnail_url'].first, work)

        puts "#{verb} work with title: #{attrs['title'].try(:first)} and id: #{work.id}"
      else
        raise "Failed to create Work with title: #{attrs['title'].try(:first)} and Identifier: #{attrs['identifier']}, error messages: #{work.try(:errors).try(:messages)}"
      end

      work
    end

    def existing_or_new_work(source)
      return @existing_or_new_work if @existing_or_new_work.present?
      @existing_or_new_work = Work.where(source: source).first
      @existing_or_new_work ||= Work.new(source: source)
    end

    def add_image(url, work)
      # clear any existing uploads so we can start from scratch
      if work && work.file_sets.size > 0
        work.file_sets.each do |f|
          f.destroy
        end
      end
      uploaded_file = Sufia::UploadedFile.create(remote_file_url: url, user: @user)

      file_set = FileSet.new
      file_set.visibility = 'open'

      actor = CurationConcerns::Actors::FileSetActor.new(file_set, @user) # voodoo...

      actor.create_metadata(work, visibility: work.visibility) do |file|
        file.permissions_attributes = work.permissions.map(&:to_hash)
      end

      actor.create_content(uploaded_file.file.file) # stutter much?
      uploaded_file.update(file_set_uri: file_set.uri)
    rescue => e
      Raven.capture_exception(e)
    end

    def clean_attrs(attrs)
      @valid_attrs.each_with_object({}) do |attr_name, hash|
        if attrs[attr_name].present?
          hash[attr_name] = attrs[attr_name]
        else
          hash[attr_name] = nil
        end
      end
    end
  end
end
