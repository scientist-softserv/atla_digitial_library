# frozen_string_literal: true

class ReindexWorksFromFileJob < ApplicationJob
  def perform(work_id)
    work = ActiveFedora::Base.find(work_id)
    work.list_source.update_index
    work.update_index
  end
end
