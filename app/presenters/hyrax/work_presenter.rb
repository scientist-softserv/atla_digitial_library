# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  class WorkPresenter < Hyrax::WorkShowPresenter
    delegate :title, :date_created, :description,
             :creator, :contributor, :subject, :publisher, :language, :embargo_release_date,
             :lease_expiration_date, :license, :source, :rights_statement, :thumbnail_id, :representative_id,
             :rendering_ids, :member_of_collection_ids, :contributing_institution, :place, :extent, :format_original,
             :format_digital, :time_period, :alternative_title, :types, :manifest_url,

             to: :solr_document

    def date
      solr_document.date.try(:to_formatted_s, :standard)
    end
  end
end
