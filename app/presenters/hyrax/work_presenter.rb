# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  class WorkPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-iiif_av plugin.
    include Hyrax::IiifAv::DisplaysIiifAv
    Hyrax::MemberPresenterFactory.file_presenter_class = Hyrax::IiifAv::IiifFileSetPresenter

    # Optional override to select iiif viewer to render
    # default :avalon for audio and video, :universal_viewer for images
    # def iiif_viewer
    #   :avalon
    # end
    delegate :title, :date_created, :description,
      :creator, :contributor, :subject, :date, :publisher, :language, :embargo_release_date,
      :lease_expiration_date, :license, :source, :rights_statement, :rights_holder, :thumbnail_id, :representative_id,
      :rendering_ids, :member_of_collection_ids, :contributing_institution, :place, :extent, :format_original,
      :format_digital, :time_period, :alternative_title, :types, :remote_manifest_url, :has_manifest, :ancestor_collection_ids,
      :ancestor_relationships,
      to: :solr_document

    # # Override the override so that it does not try to use the avalon player
    # def iiif_viewer
    #   :universal_viewer
    # end

    def iiif_viewer?
      has_manifest.present? &&
        has_manifest.first == "1" &&
        representative_id.present? &&
        representative_presenter.present? &&
        iiif_media? &&
        Hyrax.config.iiif_image_server? &&
        members_include_viewable?
    end
    alias universal_viewer? iiif_viewer?

    def iiif_media?
      representative_presenter.image? ||
        representative_presenter.video? ||
        representative_presenter.audio?
    end

    def members_include_viewable?
      file_set_presenters.any? { |presenter| (presenter.image? || presenter.video? || presenter.audio?) && current_ability.can?(:read, presenter.id) }
    end


    def ancestor_collections
      Collection.where(id: self.ancestor_collection_ids)
    end

    # use this to select urls from identifier
    def url
      solr_document.identifier.select {|i| i.match('http')}
    end

  end
end
