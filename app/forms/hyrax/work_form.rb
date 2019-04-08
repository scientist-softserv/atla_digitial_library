# Generated via
#  `rails generate hyrax:work Work`
module Hyrax
  # Generated form for Work
  class WorkForm < Hyrax::Forms::WorkForm

    # begin added code
    # replace Sufia `:collection_ids` with Hyrax `:member_of_collection_ids`
    self.terms = [:title, :creator, :date, :contributing_institution, :description, :subject, :place, :contributor, :extent, :format_original, :language, :publisher, :alternative_title, :time_period, :format_digital, :types, :identifier, :relation, :rights_statement, :rights_holder, :remote_manifest_url, :thumbnail_id, :keyword, :representative_id, :files, :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo, :visibility_during_lease, :lease_expiration_date, :visibility_after_lease, :visibility, :ordered_member_ids, :source, :in_works_ids, :member_of_collection_ids, :admin_set_id]

    self.required_fields = [:title]
    # end added code

    self.model_class = ::Work
    self.terms += [:resource_type]
  end
end
