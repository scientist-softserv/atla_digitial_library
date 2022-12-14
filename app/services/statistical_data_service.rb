class StatisticalDataService
  def initialize
    @conn = RSolr.connect(Blacklight.connection_config.except(:adapter))
  end

  def update_home_page
    work_count_formatted = ActiveSupport::NumberHelper.number_to_delimited(Work.count)
    contributor_count_formatted = ActiveSupport::NumberHelper.number_to_delimited(contributor_count)
    string = "Discover <strong>#{work_count_formatted}</strong> images, texts,"\
             " videos, and sounds from <strong>#{contributor_count_formatted}</strong> contributors"

    ContentBlock.announcement_text = string
  end

  def update_institutions_page
    rewrite_content
  end

  private

    def contributor_count
      results = @conn.get 'select',
params: { q: '', facet: true, "facet.field": 'contributing_institution_sim', "facet.mincount": 1, rows: 0 }
      results['facet_counts']['facet_fields']['contributing_institution_sim'].length / 2
    end

    def rewrite_content
      document = Nokogiri::HTML.parse(ContentBlock.institutions_page.value)
      tags = document.xpath('//a')

      tags.each do |tag|
        work_count = get_work_count_from tag

        if tag.content.match?(/\s\(\d{1,3}(,\d{3})*(\.\d+)?\)$/)
          tag.content = tag.content.gsub(/\s\(\d{1,3}(,\d{3})*(\.\d+)?\)$/, " (#{work_count})")
        else
          tag.content += " (#{work_count})"
        end
      end

      ContentBlock.institutions_page = document.to_html
    end

    def get_work_count_from(tag)
      work_count =
        if tag.attributes['href'].value.match?(/catalog/)
          institution_name = CGI.parse(URI.parse(tag.attributes['href'].value)
                                .query)['f[contributing_institution_sim][]']
                                .first
          get_work_count_by_contributing_institution institution_name
        elsif tag.attributes['href'].value.match?(/collections/)
          institution_slug = URI.parse(tag.attributes['href'].value).path.split('/').last
          collection_work_count institution_slug
        end

      ActiveSupport::NumberHelper.number_to_delimited(work_count || 0)
    end

    def get_work_count_by_contributing_institution(contributing_institution)
      @institution_map ||= fetch_contributing_institutions
      @institution_map[contributing_institution]
    end

    def fetch_contributing_institutions
      results = @conn.get 'select',
  params: { q: '', facet: true, 'facet.field': 'contributing_institution_sim', 'facet.mincount': 1, rows: 0 }
      results = results['facet_counts']['facet_fields']['contributing_institution_sim']
      results = results.partition.each_with_index { |_, i| i.even? }
      results[0]
        .zip(results[1])
        .each_with_object({}) { |(key, val), hash| hash[key] = val }
    end

    def collection_work_count(slug)
      collection = Collection.find slug

      ids = fetch_collection_member_count collection.id
      ids = fetch_child_collection_counts collection if ids.empty?

      ids.uniq.length
    end

    def fetch_child_collection_counts(collection)
      collection
        .child_collection_ids
        .map { |id| fetch_collection_member_count id }.flatten
    end

    def fetch_collection_member_count(id)
      res = @conn.get 'select',
  params: { fq: ['{!terms f=has_model_ssim}Work', '-suppressed_bsi:true', "member_of_collection_ids_ssim:#{id}"],
            fl: 'id', rows: 1_000_000 }
      res['response']['docs'].map { |k| k['id'] } || []
    end
end
