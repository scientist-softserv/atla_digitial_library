require 'iso8601'

class Harvester < ActiveRecord::Base
  belongs_to :user
  has_many :harvest_runs

  def importer
    # create an importer based on harvester
    @importer ||= self.importer_name.constantize.new(self.base_url,
                                                     self.thumbnail_url,
                                                     self.right_statement,
                                                     self.institution_name,
                                                     self.user,
                                                     self.admin_set_id,
                                                     self.external_set_id,
                                                     self.metadata_prefix,
                                                     {})
  end

  def collection
    Collection.find collection_id
  end

  def collection=(id)
    collection_id = id if Collection.find id or id == nil
  end

  def importer_names_enum
    [
      ["OAI - Dublin Core", "OAI::DC::Importer"],
      ["OAI - Qualified Dublin Core", "OAI::QualifiedDC::Importer"],
    ]
  end

  def frequency_enums
    # these duration values use ISO 8601 Durations (https://en.wikipedia.org/wiki/ISO_8601#Durations)
    # TLDR; all durations are prefixed with 'P' and the parts are a number with the type of duration.
    # i.e. P1Y2M3W4DT5H6M7S == 1 Year, 2 Months, 3 Weeks, 4 Days, 5 Hours, 6 Minutes, 7 Seconds
    [['Daily', 'P1D'], ['Monthly', 'P1M'], ['Yearly', 'P1Y'], ['Once (on save)', 'PT0S']]
  end

  def frequency=(frequency)
    write_attribute(:frequency, ISO8601::Duration.new(frequency).to_s)
  end

  def frequency
    ISO8601::Duration.new read_attribute(:frequency) if read_attribute(:frequency)
  end

  def schedulable?
    frequency.to_seconds != 0
  end

  def next_harvest_at
    (last_harvested_at || Time.current) + frequency.to_seconds if schedulable? and last_harvested_at.present?
  end
end
