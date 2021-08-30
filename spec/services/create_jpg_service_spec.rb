require 'rails_helper'

RSpec.describe CreateJpgService, clean: true do
  # let(:user) { create(:user) }
  let(:pdf_file) {
    create(:uploaded_file,
          #  user: user,
           file: File.open(::Rails.root.join('spec/fixtures/pdf/archive.pdf')))
  }

  it 'takes in a pdf and returns a file with the pdf and jpgs for each page' do
    files = CreateJpgService.create_jpgs([pdf_file])
    expect(files).to include(pdf_file)
    expect(files.count).to eq 7
  end
end
