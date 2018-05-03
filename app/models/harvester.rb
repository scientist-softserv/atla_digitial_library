require 'iso8601'

class Harvester < ActiveRecord::Base
  def collection
    Collection.find collection_id
  end

  def collection=(id)
    collection_id = id if Collection.find id or id == nil
  end

  def user
    User.where(id: user_id).first
  end

  def importer_enums
    [["OAI Mods - Dublin Core", "oai_mods_dc"]]
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
end
