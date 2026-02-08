# frozen_string_literal: true

module SystemTestHelpers
  module TurboStreamHelpers
    # Wait for a flash message to appear
    #
    # @param message [String] The flash message text to wait for
    # @param timeout [Integer] Maximum time to wait in seconds (default: 5)
    #
    # @example
    #   wait_for_flash "User was created"
    def wait_for_flash(message, timeout: 5)
      assert_text message, wait: timeout
    end

    # Wait for Turbo Stream to complete by checking for success message
    #
    # @param success_message [String, nil] Optional success message to wait for
    # @param modal_id [String, nil] Optional modal ID to wait for closure
    #
    # @example
    #   wait_for_turbo_stream success_message: "User was created"
    #   wait_for_turbo_stream modal_id: "#modal"
    def wait_for_turbo_stream(success_message: nil, modal_id: nil)
      wait_for_flash(success_message) if success_message
      wait_for_modal_to_close(modal_id: modal_id) if modal_id
    end
  end
end
