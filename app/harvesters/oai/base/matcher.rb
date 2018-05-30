module OAI::Base
  class Matcher
    attr_accessor :to, :from, :parsed, :if
    def initialize(args)
      args.each do |k, v|
        send("#{k}=", v)
      end
    end

    def result(parser, content)
      return nil if self.if && !self.if.call(parser, content)

      @result = content
      if self.split
        @result = @result.split(/\s*[:|]\s*/)
      end

      if self.parsed
        @result = send("parse_#{key}", @result)
      end

      return @result
    end

    def parse_language(src)
      LanguageList::COMMON_LANGUAGES.each do |lang|
        if src == lang.iso_639_1 or src == lang.iso_639_3
          return lange.name
        end
      end

      src
    end

    def parse_format(src)
      case src
      when 'application/pdf','pdf', 'PDF'
        'pdf'
      when 'image/jpeg', 'image/jpg', 'jpeg', 'jpg', 'JPEG', 'JPG'
        'JPEG'
      when 'image/tiff', 'image/tif', 'tiff', 'tif', 'TIFF', 'TIF'
        'TIFF'
      when 'image/jp2', 'jp2', 'JP2'
        'JP2'
      when 'image/png', 'png', 'PNG'
        'PNG'
      when 'image/gif', 'gif', 'GIF'
        'GIF'
      when 'video/mp4', 'mp4', 'MP4'
        'MP4'
      when 'video/ogg', 'ogg', 'OGG'
        'OGG'
      when 'video/vnd.avi', 'video/avi', 'avi', 'AVI'
        'AVI'
      when 'audio/aac', 'aac', 'AAC'
        'AAC'
      when 'audio/mp4', 'mp4', 'MP4'
        'MP4'
      when 'audio/mpeg', 'audio/mp3', 'audio/mpeg3', 'mpeg', 'MPEG', 'mp3', 'MP3', 'mpeg3', 'MPEG3'
        'MPEG'
      when 'audio/ogg', 'ogg', 'OGG'
        'OGG'
      when 'audio/aiff', 'aiff', 'AIFF'
        'AIFF'
      when 'audio/webm', 'webm', 'WEBM'
        'WEBM'
      when 'audio/wav', 'wav', 'WAV'
        'WAV'
      when 'text/csv', 'csv', 'CSV'
        'CSV'
      when 'text/html', 'html', 'HTML'
        'HTML'
      when 'text/rtf', 'rtf', 'RTF'
        'RTF'
      else
        src
      end
    end
  end
end
