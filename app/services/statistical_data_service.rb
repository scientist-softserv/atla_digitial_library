class StatisticalDataService
  def initialize
    @conn = RSolr.connect(Blacklight.connection_config.except(:adapter))
  end

  def update_home_page
    work_count = Work.count
    contributor_count = Work.contributing_institutions.count
    string = "Discover <strong>#{work_count}</strong> images, texts, videos and sounds from <strong>#{contributor_count}</strong> contributors"

    ContentBlock.announcement_text = string
  end

  def update_institutions_page
    rewrite_content
  end

  private

  def rewrite_content
    document = Nokogiri::HTML.parse(ContentBlock.institutions_page.value)
    tags = document.xpath('//a')

    tags.each do |tag|
      work_count = get_work_count_from tag

      if tag.content.match?(/\s\([^\d]*(\d+)[^\d]*\)$/)
        tag.content = tag.content.gsub(/\s\([^\d]*(\d+)[^\d]*\)$/, " (#{work_count})")
      else
        tag.content += " (#{work_count})"
      end
    end

    ContentBlock.institutions_page = document.to_html
  end

  def get_work_count_from(tag)
    work_count =
      if tag.attributes['href'].value.match?(/catalog/)
        institution_name = CGI.parse(URI.parse(tag.attributes['href'].value).query)['f[contributing_institution_sim][]'].first
        get_work_count_by_contributing_institution institution_name
      elsif tag.attributes['href'].value.match?(/collections/)
        institution_name = URI.parse(tag.attributes['href'].value).path.split('/').last
        collection_works_count_by_slug institution_name
      end

    work_count || 0
  end

  def get_work_count_by_contributing_institution(contributing_institution)
    @institution_map ||= fetch_contributing_institutions
    @institution_map[contributing_institution]
  end

  def fetch_contributing_institutions
    results = @conn.get 'select', params: { q: 'has_model_ssim:Work', facet: true, "facet.field": 'contributing_institution_sim', rows: 0 }
    results = results['facet_counts']['facet_fields']['contributing_institution_sim']
    results = results.partition.each_with_index { |_, i| i.even? }
    results[0]
      .zip(results[1])
      .each_with_object({}) { |(key, val), hash| hash[key] = val }
  rescue
    0
  end

  def collection_works_count_by_slug(slug)
    collection = Collection.find slug

    return 0 if collection.nil?

    collection.works_count
  end
end