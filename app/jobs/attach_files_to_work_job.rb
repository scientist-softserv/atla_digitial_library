# OVERRIDE: Hyrax 2.9.1 to add derived to uploaded files

class AttachFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform(work, uploaded_files, **work_attributes)
    validate_files!(uploaded_files)
    depositor = proxy_or_depositor(work)
    user = User.find_by_user_key(depositor)
    work_permissions = work.permissions.map(&:to_hash)
    metadata = visibility_attributes(work_attributes)
    visibility_attributes(work_attributes)
    uploaded_files.in_groups_of(10, false) do |upload_group|
      upload_group.each do |uploaded_file|
        next if uploaded_file.file_set_uri.present?
        actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
        uploaded_file.update(file_set_uri: actor.file_set.uri)
        actor.file_set.permissions_attributes = work_permissions
        metadata[:is_derived] = uploaded_file.derived?
        actor.create_metadata(metadata)
        actor.create_content(uploaded_file)
        actor.attach_to_work(work)
      end
      work.reload
    end
  end

  private

    # The attributes used for visibility - sent as initial params to created FileSets.
    def visibility_attributes(attributes)
      attributes.slice(:visibility, :visibility_during_lease,
                       :visibility_after_lease, :lease_expiration_date,
                       :embargo_release_date, :visibility_during_embargo,
                       :visibility_after_embargo)
    end

    def validate_files!(uploaded_files)
      uploaded_files.each do |uploaded_file|
        next if uploaded_file.is_a? Hyrax::UploadedFile
        raise ArgumentError,
              "Hyrax::UploadedFile required, but #{uploaded_file.class} received: #{uploaded_file.inspect}"
      end
    end

    ##
    # A work with files attached by a proxy user will set the depositor as the intended user
    # that the proxy was depositing on behalf of. See tickets #2764, #2902.
    def proxy_or_depositor(work)
      work.on_behalf_of.presence || work.depositor
    end
end
