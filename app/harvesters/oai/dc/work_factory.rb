module OAI::DC
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
      work = WorkFactory.existing_or_new_work(attrs['identifier'])
      verb = work.new_record? ? "created" : "updated"

      collections = attrs['collection'].map do |collection_title|
        collection = Collection.where(title: [collection_title]).first
        collection ||= Collection.create(title: [collection_title])
      end

      clean_attrs(attrs).each do |key, value|
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

    def self.existing_or_new_work(identifier)
      if Work.where(identifier: identifier).present?
        return Work.where(identifier: identifier).first
      end

      Work.new(identifier: identifier)
    end

    def add_image(url, work)
      open(url) do |f|
        uploaded_file = Sufia::UploadedFile.create(file: f, user: @user) # this sort of behavior might need to be added to the Work model (local project)

        file_set = FileSet.new
        file_set.visibility = 'open'

        actor = CurationConcerns::Actors::FileSetActor.new(file_set, @user) # voodoo...

        actor.create_metadata(work, visibility: work.visibility) do |file|
          file.permissions_attributes = work.permissions.map(&:to_hash)
        end

        actor.create_content(uploaded_file.file.file) # stutter much?
        uploaded_file.update(file_set_uri: file_set.uri)
      end
    rescue
      # OaiImporter::LOGGER.error("Failed to add image url (#{url}) to work with identifier #{work.identifier}")
    end

    def clean_attrs(attrs)
      @valid_attrs.each_with_object({}) do |attr_name, hash|
        hash[attr_name] = attrs[attr_name] if attrs[attr_name].present?
      end
    end
  end
end
