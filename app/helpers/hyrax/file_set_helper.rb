# override Hyrax 2.6
# add html to list of display partials
# remove 'pdf' and add 'image'

module Hyrax::FileSetHelper
  def parent_path(parent)
    if parent.is_a?(Collection)
      main_app.collection_path(parent)
    else
      polymorphic_path([main_app, parent])
    end
  end

  # REVIEW: Since this media display could theoretically work for
  #         any object that inplements to_s and the Mime Type methos (image? audio? ...),
  #         Should this really be in file_set or could it be in it's own helper class like media_helper?
  def media_display(presenter, locals = {})
    render media_display_partial(presenter),
           locals.merge(file_set: presenter)
  end

  def media_display_partial(file_set)
    'hyrax/file_sets/media_display/' +
      if file_set.pdf?
        'image' # order dependant?, remove 'pdf' and add 'image'
      elsif file_set.video?
        'video'
      elsif file_set.audio?
        'audio'
      elsif file_set.image?
        'image'
      elsif file_set.html?
        'html'
      elsif file_set.office_document?
        'office_document'
      else
        'default'
      end
  end
  # rubocop:enable Metrics/MethodLength
end
