require 'rails_helper'

RSpec.describe Work do
  subject(:work) { described_class.new }

  describe 'metadata' do
    it_behaves_like 'a model with hyrax basic metadata', except: []

    it 'has an #alternative_title' do
      is_expected
        .to have_editable_property(:alternative_title)
        .with_predicate(RDF::Vocab::DC.alternative)
    end

    it 'has a #contributing_institution' do
      is_expected
        .to have_editable_property(:contributing_institution)
        .with_predicate(RDF::Vocab::DC.contributor)
    end

    it 'has a #contributor' do
      is_expected
        .to have_editable_property(:contributor)
        .with_predicate(RDF::Vocab::DC11.contributor)
    end

    it 'has a #creator' do
      is_expected
        .to have_editable_property(:creator)
        .with_predicate(RDF::Vocab::DC11.creator)
    end

    it 'has a #date' do
      is_expected
        .to have_editable_property(:date)
        .with_predicate(RDF::Vocab::DC11.date)
    end

    it 'has a #description' do
      is_expected
        .to have_editable_property(:description)
        .with_predicate(RDF::Vocab::DC11.description)
    end

    it 'has an #extent' do
      is_expected
        .to have_editable_property(:extent)
        .with_predicate(RDF::Vocab::DC.extent)
    end

    it 'has a #format_digital' do
      is_expected
        .to have_editable_property(:format_digital)
        .with_predicate(RDF::Vocab::DC11.format)
    end

    it 'has a #format_original' do
      is_expected
        .to have_editable_property(:format_original)
        .with_predicate(RDF::Vocab::DC.medium)
    end

    it 'has an #identifier' do
      is_expected
        .to have_editable_property(:identifier)
        .with_predicate(RDF::Vocab::DC.identifier)
    end

    it 'has a #language' do
      is_expected
        .to have_editable_property(:language)
        .with_predicate(RDF::Vocab::DC11.language)
    end

    it 'has a #original_url' do
      is_expected
        .to have_editable_property(:original_url)
        .with_predicate(RDF::Vocab::DC.URI)
    end

    it 'has a #place' do
      is_expected
        .to have_editable_property(:place)
        .with_predicate(RDF::Vocab::DC.coverage)
    end

    it 'has a #publisher' do
      is_expected
        .to have_editable_property(:publisher)
        .with_predicate(RDF::Vocab::DC11.publisher)
    end

    it 'has a #relation' do
      is_expected
        .to have_editable_property(:relation)
        .with_predicate(RDF::Vocab::DC11.relation)
    end

    it 'has a #resource_type' do
      is_expected
        .to have_editable_property(:resource_type)
        .with_predicate(RDF::Vocab::DC.type)
    end

    it 'has a #rights_holder' do
      is_expected
        .to have_editable_property(:rights_holder)
        .with_predicate(RDF::Vocab::DC.rightsHolder)
    end

    it 'has a #source' do
      is_expected
        .to have_editable_property(:source)
        .with_predicate(RDF::Vocab::DC.source)
    end

    it 'has a #subject' do
      is_expected
        .to have_editable_property(:subject)
        .with_predicate(RDF::Vocab::DC11.subject)
    end

    it 'has a #thumbnail_url' do
      is_expected
        .to have_editable_property(:thumbnail_url)
        .with_predicate(RDF::Vocab::DC.hasVersion)
    end

    it 'has a #time_period' do
      is_expected
        .to have_editable_property(:time_period)
        .with_predicate(RDF::Vocab::DC.temporal)
    end

    it 'has a #title' do
      is_expected
        .to have_editable_property(:title)
        .with_predicate(RDF::Vocab::DC.title)
    end

    it 'has #types' do
      is_expected
        .to have_editable_property(:types)
        .with_predicate(RDF::Vocab::DC11.type)
    end
  end

  describe '#rights' do
    let(:values) { [:a_license, :another_license] }

    it 'is aliased to #license' do
      expect { work.license = values }
        .to change { work.rights.to_a }
        .to contain_exactly(*values)
    end

    it 'can set license' do
      expect { work.rights = values }
        .to change { work.license.to_a }
        .to contain_exactly(*values)
    end
  end

  describe '#ancestor_collections' do
    before(:example) do
      @grandparent_collection = Collection.new(title: ['Grandparent Collection'])
      @parent_collection = Collection.new(title: ['Parent Collection'])
      @parent_collection.member_of_collections << @grandparent_collection
      work.member_of_collections << @parent_collection
    end

    it 'returns both its parent and grandparent collection' do
      expect(work.member_of_collections)
        .to_not include(@grandparent_collection)
      expect(work.ancestor_collections)
        .to include(@parent_collection)
        .and include(@grandparent_collection)
    end
  end
end
