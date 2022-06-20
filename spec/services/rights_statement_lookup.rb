require 'rails_helper'
# rubocop:disable RSpec/FilePath
RSpec.describe RightsStatementLookup do
  describe 'In Copyright' do
    it 'returns the html_safe description that matches a rights statement id' do
      expect(RightsStatementLookup.description_for('http://rightsstatements.org/vocab/InC/1.0/'))
        .to include('InC/1.0/</a>')
    end
  end

  describe 'No Copyright - Other Known Legal Restrictions' do
    it 'returns the html_safe description that matches a rights statement id' do
      expect(RightsStatementLookup.description_for('http://rightsstatements.org/vocab/NoC-OKLR/1.0/'))
        .to include("<a href='https://rightsstatements.org/vocab/NoC-OKLR/1.0/' target=\"_blank\">https://rightsstatements.org/vocab/NoC-OKLR/1.0/</a>")
    end
  end
  # rubocop:enable RSpec/FilePath
end
