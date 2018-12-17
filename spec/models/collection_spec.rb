require 'rails_helper'

RSpec.describe Collection do
  subject(:collection) { described_class.new }

  describe '#bytes' do
    it 'is 0' do
      expect(collection.bytes).to eq 0
    end

    context 'with members' do
      it 'is hard coded to 0'
    end
  end

  describe '#metadata' do
    it 'has a #file_name' do
      is_expected
        .to have_editable_property(:file_name)
        .with_predicate(RDF::Vocab::DC.MediaTypeOrExtent)
    end

    it 'has an #institution' do
      is_expected
        .to have_editable_property(:institution)
        .with_predicate(RDF::Vocab::FOAF.based_near)
    end

    it 'has a #name_code' do
      is_expected
        .to have_editable_property(:name_code)
        .with_predicate(RDF::Vocab::DC.identifier)
    end

    it 'has a #pub_place' do
      is_expected
        .to have_editable_property(:pub_place)
        .with_predicate(RDF::Vocab::DC.Location)
    end
  end
end
