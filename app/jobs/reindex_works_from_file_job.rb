# frozen_string_literal: true

class ReindexWorksFromFileJob < ApplicationJob
  def perform(work_id)
    work = ActiveFedora::Base.find(work_id)
    # work.update_index
    work.list_source.update_index
  end
end
