require 'rails_helper'

RSpec.describe CreateJpgService, clean: true do
  let(:pdf_file) do
    create(:uploaded_file,
           file: File.open(::Rails.root.join('spec/fixtures/pdf/archive.pdf')))
  end
  let(:user) { FactoryBot.create(:user) }

  it 'takes in a pdf and returns a file with jpgs for each page' do
    files = CreateJpgService.new([pdf_file], user).create_jpgs
    expect(files).not_to include(pdf_file)
    expect(files.count).to eq 6
  end
end
