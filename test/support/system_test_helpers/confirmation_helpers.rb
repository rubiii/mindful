# frozen_string_literal: true

module SystemTestHelpers
  module ConfirmationHelpers
    # Confirm an action in a confirmation modal
    #
    # @param button_text [String] The confirmation button text (default: "Confirm")
    # @param modal_id [String] The CSS selector for the confirm modal (default: "#confirm-modal")
    #
    # @example
    #   confirm_action
    #   confirm_action button_text: "Yes, delete it"
    def confirm_action(button_text: "Confirm", modal_id: "#confirm-modal")
      within modal_id do
        click_on button_text
      end
    end
  end
end
