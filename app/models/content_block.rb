# This file was moved over from hyrax to allow for "participate" and "institutions" pages.
# Lines/blocks that differ from original source are commented with a prefix of "UPGRADE NOTE"
class ContentBlock < ActiveRecord::Base
  # The keys in this registry are "public" names for collaborator
  # objects, and the values are reserved names of ContentBlock
  # instances, which Hyrax uses as identifiers. Values also correspond
  # to names of messages that can be sent to the ContentBlock class to
  # return defined ContentBlock instances.
  NAME_REGISTRY = {
    marketing: :marketing_text,
    researcher: :featured_researcher,
    announcement: :announcement_text,
    about: :about_page,
    participate: :participate_page,
    search_tips: :search_tips_page,
    help: :help_page,
    institutions: :institutions_page,
    terms: :terms_page,
    agreement: :agreement_page
  }.freeze

  # NOTE: method defined outside the metaclass wrapper below because
  # `for` is a reserved word in Ruby.
  def self.for(key)
    key = key.respond_to?(:to_sym) ? key.to_sym : key
    raise ArgumentError, "#{key} is not a ContentBlock name" unless whitelisted?(key)

    ContentBlock.public_send(NAME_REGISTRY[key])
  end

  class << self
    def whitelisted?(key)
      NAME_REGISTRY.include?(key)
    end

    def marketing_text
      find_or_create_by(name: 'marketing_text')
    end

    def marketing_text=(value)
      marketing_text.update(value: value)
    end

    def announcement_text
      find_or_create_by(name: 'announcement_text')
    end

    def announcement_text=(value)
      announcement_text.update(value: value)
    end

    def featured_researcher
      find_or_create_by(name: 'featured_researcher')
    end

    def featured_researcher=(value)
      featured_researcher.update(value: value)
    end

    def about_page
      find_or_create_by(name: 'about_page')
    end

    def about_page=(value)
      about_page.update(value: value)
    end

    # UPGRADE NOTE: these methods differ from original source. Changed to allow for a "participate" page.
    def participate_page
      find_or_create_by(name: 'participate_page')
    end

    def participate_page=(value)
      participate_page.update(value: value)
    end

    def search_tips_page
      find_or_create_by(name: 'search_tips_page')
    end

    def search_tips_page=(value)
      search_tips_page.update(value: value)
    end
    # END UPGRADE NOTE

    def agreement_page
      find_by(name: 'agreement_page') ||
        create(name: 'agreement_page', value: default_agreement_text)
    end

    def agreement_page=(value)
      agreement_page.update(value: value)
    end

    def help_page
      find_or_create_by(name: 'help_page')
    end

    def help_page=(value)
      help_page.update(value: value)
    end

    # UPGRADE NOTE: these methods differ from original source. Changed to allow for an "institutions" page.
    def institutions_page
      find_or_create_by(name: 'institutions_page')
    end

    def institutions_page=(value)
      institutions_page.update(value: value)
    end
    # END UPGRADE NOTE

    def terms_page
      find_by(name: 'terms_page') ||
        create(name: 'terms_page', value: default_terms_text)
    end

    def terms_page=(value)
      terms_page.update(value: value)
    end

    def default_agreement_text
      ERB.new(
        IO.read(
          Hyrax::Engine.root.join('app', 'views', 'hyrax', 'content_blocks', 'templates', 'agreement.html.erb')
        )
      ).result
    end

    def default_terms_text
      ERB.new(
          IO.read(
            Hyrax::Engine.root.join('app', 'views', 'hyrax', 'content_blocks', 'templates', 'terms.html.erb')
          )
        ).result
    end
  end
end
