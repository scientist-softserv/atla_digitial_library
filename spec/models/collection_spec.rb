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
end
