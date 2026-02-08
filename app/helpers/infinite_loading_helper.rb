# frozen_string_literal: true

module InfiniteLoadingHelper
  INFINITE_FRAME_ID = "infinite_loading"

  # Renders a lazy-loading Turbo Frame that requests the next page via Turbo Stream.
  #
  # @param url [Hash, nil] A URL hash for `url_for` (defaults to current controller/action).
  # @param pagy [Pagy, nil] The Pagy object (defaults to `@pagy`).
  # @return [String, nil] The Turbo Frame markup or nil when no next page exists.
  # @raise [ArgumentError] If neither `pagy:` nor `@pagy` is present.
  def infinite_loading(url: nil, pagy: nil)
    pagy ||= @pagy
    raise ArgumentError, "Missing pagy: argument or @pagy variable" unless pagy

    return unless pagy.next

    url ||= { controller: controller_name, action: action_name }
    src = url_for url.merge(page: pagy.next, format: :turbo_stream)

    turbo_frame_tag(INFINITE_FRAME_ID, src:, loading: :lazy, "aria-busy": "true") do
      concat icon(:load_more)
      concat tag.span("Loading more", class: "is-sr-only")
    end
  end

  # Renders a Turbo Stream update that updates or removes the infinite loading frame
  # based on pagination state.
  #
  # @param url [Hash, nil] A URL hash for `url_for` (defaults to current controller/action).
  # @param pagy [Pagy, nil] The Pagy object (defaults to `@pagy`).
  # @return [String] Turbo Stream markup when rendered.
  # @raise [ArgumentError] If neither `pagy:` nor `@pagy` is present
  def refresh_infinite_loading(url: nil, pagy: nil)
    pagy ||= @pagy
    raise ArgumentError, "Missing pagy: argument or @pagy variable" unless pagy

    url ||= { controller: controller_name, action: action_name }

    if pagy.next
      turbo_stream.replace INFINITE_FRAME_ID do
        infinite_loading(url:, pagy:)
      end
    else
      turbo_stream.remove INFINITE_FRAME_ID
    end
  end
end
