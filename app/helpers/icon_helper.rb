# frozen_string_literal: true

module IconHelper
  def icon(icon, options = {})
    classes = class_names options.delete(:class), "icon"

    tag.span class: classes, **options do
      render "shared/icons/#{icon}"
    end
  end
end
