# frozen_string_literal: true

require 'rails_helper'
require 'libxml'

module Bulkrax
  RSpec.describe OaiEntry, type: :model do
    let(:entry) { Bulkrax::OaiQualifiedDcEntry.new(importerexporter: importer) }
    let(:importer) { FactoryBot.build(:bulkrax_importer_oai) }
    let(:collection) { FactoryBot.build(:collection) }

    describe 'no source' do
      let(:raw_record) { OAI::GetRecordResponse.new(LibXML::XML::Document.file('spec/fixtures/oai_qdc.xml')) }

      it 'implements parser field institution_name if no dc:source field' do
        entry.instance_variable_set("@raw_record", raw_record)
        allow(entry).to receive(:find_or_create_collection_ids).and_return([])
        entry.build_metadata
        expect(entry.parsed_metadata['contributing_institution']).to eq(["Fake Institution"])
      end
    end

    describe 'with source' do
      let(:raw_record) do
        OAI::GetRecordResponse.new(LibXML::XML::Document.file('spec/fixtures/oai_qdc_with_source.xml'))
      end

      it 'reads dc:source if provided' do
        entry.instance_variable_set("@raw_record", raw_record)
        allow(entry).to receive(:find_or_create_collection_ids).and_return([])
        entry.build_metadata
        expect(entry.parsed_metadata['contributing_institution']).to eq(["Source Institution"])
      end
    end
  end
end
