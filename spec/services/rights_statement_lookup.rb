require 'rails_helper'

RSpec.describe RightsStatementLookup do

  describe 'In Copyright' do
    it 'returns the html_safe description that matches a rights statement id' do
      expect(RightsStatementLookup.description_for('http://rightsstatements.org/vocab/InC/1.0/'))
        .to include('InC/1.0/</a>')
    end
  end

  describe 'No Copyright - Other Known Legal Restrictions (http)' do
    it 'returns the html_safe description that matches a rights statement id' do
      expect(RightsStatementLookup.description_for('http://rightsstatements.org/vocab/NoC-OKLR/1.0/'))
        .to include("<a href='http://rightsstatements.org/vocab/NoC-OKLR/1.0/' target=\"_blank\">http://rightsstatements.org/vocab/NoC-OKLR/1.0/</a>")
    end
  end

  describe 'Attribution-NoDerivatives 4.0 International (https)' do
    it 'returns the description that matches a rights statement id' do
      expect(RightsStatementLookup.description_for('http://creativecommons.org/licenses/by-nd/4.0/'))
        .to include("<a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nd/4.0/\" target=\"_blank\">https://creativecommons.org/licenses/by-nd/4.0/</a>")
    end
  end
end
