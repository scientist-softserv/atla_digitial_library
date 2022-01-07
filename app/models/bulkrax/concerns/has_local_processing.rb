module Bulkrax::Concerns::HasLocalProcessing

  def contributing_institution
    parser.parser_fields['institution_name']
  end

  def add_local
    # If the contibuting insts is empty or if it only contains empty strings eg. [""]
    if self.parsed_metadata['contributing_institution'].blank? ||
        !self.parsed_metadata['contributing_institution'].detect { |i| i.present? }
      self.parsed_metadata['contributing_institution'] = [contributing_institution].compact
    end
  end

  def self.matcher_class
    Bulkrax::AtlaMatcher
  end

  def fetch_remote_file_link(url)
    uri = URI.parse(url)
    page = Nokogiri::HTML(URI.open(uri))
    nodeset = page.css('a[href]')
    hrefs = nodeset.map { |element| element["href"] }
    video_link = hrefs.grep(/.mp4/)&.first
    audio_link = hrefs.grep(/.mp3/)&.first
    pdf_link = hrefs.grep(/.pdf/)&.first
    remote_file_link = if video_link.present?
                         url + video_link
                       elsif audio_link.present?
                         url + audio_link
                       elsif pdf_link.present?
                          url + pdf_link
                       else
                         ""
                       end
    remote_file_link
  end


end
