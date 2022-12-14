## Override file from Hyrax 2.5.1
## Add functionality for breadcrumb generated from #add_back_to_search_crumb method in WorksController
## in #render method. Add CSS classes for styling control. Diffs from original file are denoted with
## a CUSTOM tag.
#
# The BootstrapBreadcrumbsBuilder is a Bootstrap compatible breadcrumb builder.
# It provides basic functionalities to render a breadcrumb navigation according to Bootstrap's conventions.
#
# BootstrapBreadcrumbsBuilder accepts a limited set of options:
#
# You can use it with the :builder option on render_breadcrumbs:
#     <%= render_breadcrumbs builder: Hyrax::BootstrapBreadcrumbsBuilder %>
#
class Hyrax::BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  include ActionView::Helpers::OutputSafetyHelper
  def render
    return "" if @elements.blank?
    # begin CUSTOM block
    @back_to_search_breadcrumb = @elements.pop if @elements.last.options[:class]&.include?('back-to-search')
    # end CUSTOM block

    @context.content_tag(:nav, breadcrumbs_options) do
      # CUSTOM changes to original line: save breadcrumbs into variable, add CSS classes
      record_breadcrumbs = @context.content_tag(:ol, { class: 'breadcrumb-list col-md-9' }) do
        safe_join(@elements.uniq.collect { |e| render_element(e) })
      end

      # begin CUSTOM block
      if @back_to_search_breadcrumb.present?
        back_to_search_link = @context.link_to(
          @context.truncate(
            compute_name(@back_to_search_breadcrumb),
            length: 30,
            separator: ' '
          ),
          compute_path(@back_to_search_breadcrumb),
          @back_to_search_breadcrumb.options
        )
        record_breadcrumbs += back_to_search_link.to_s
      end
      record_breadcrumbs
      # end CUSTOM block
    end
  end

  def render_element(element)
    html_class = 'active' if @context.current_page?(compute_path(element)) || element.options["aria-current"] == "page"

    @context.content_tag(:li, class: html_class) do
      @context.link_to_unless(html_class == 'active',
@context.truncate(compute_name(element), length: 30, separator: ' '), compute_path(element), element.options)
    end
  end

  def breadcrumbs_options
    { class: 'breadcrumb', role: "region", "aria-label" => "Breadcrumb" }
  end
end
