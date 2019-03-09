require 'rails_helper'

RSpec.describe RightsStatementLookup do

  describe '#description_for' do
    it 'returns the html_safe description that matches a rights statement id' do
      expect(RightsStatementLookup.description_for('http://rightsstatements.org/vocab/InC/1.0/'))
        .to include('InC/1.0/</a>')
    end
  end
end
