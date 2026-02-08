# frozen_string_literal: true

module TooltipHelper
  TOOLTIP_PLACEMENTS = %w[
    top top-start top-end
    right right-start right-end
    bottom bottom-start bottom-end
    left left-start left-end
    auto auto-start auto-end
  ].freeze

  # Wraps a given block in a tooltip element.
  def tooltip(text, options = {}, &block)
    placement = options.delete(:placement).to_s.presence || "left"
    validate_tooltip_placement(placement)

    data = options.delete(:data) || {}
    data.merge!(controller: "tooltip", tooltip_target: "trigger", tooltip_content: text, tooltip_placement: placement)

    tag.span **options, data:, &block
  end

  private

  def validate_tooltip_placement(placement)
    return if TOOLTIP_PLACEMENTS.include?(placement)
    raise ArgumentError, "Invalid placement: #{placement}, valid placements: #{TOOLTIP_PLACEMENTS.join(', ')}"
  end
end
