# frozen_string_literal: true

module SystemTestHelpers
  module ModalHelpers
    # Open a modal by clicking a button or link
    #
    # @param button_text [String] The text of the button/link to click
    # @param modal_id [String] The CSS selector for the modal (default: "#modal")
    #
    # @example
    #   open_modal "Add User"
    #   open_modal "Edit", modal_id: "#edit-modal"
    def open_modal(button_text, modal_id: "#modal")
      click_on button_text
      assert_selector "#{modal_id} .modal.is-active"
    end

    # Wait for modal to close after an action
    #
    # @param modal_id [String] The CSS selector for the modal (default: "#modal")
    # @param timeout [Integer] Maximum time to wait in seconds (default: 5)
    #
    # @example
    #   wait_for_modal_to_close
    #   wait_for_modal_to_close modal_id: "#confirm-modal"
    def wait_for_modal_to_close(modal_id: "#modal", timeout: 5)
      assert_no_selector "#{modal_id} .modal.is-active", wait: timeout
    end

    # Close a modal manually by clicking Cancel or close button
    #
    # @param modal_id [String] The CSS selector for the modal (default: "#modal")
    # @param button_text [String] The text of the button to click (default: "Cancel")
    #
    # @example
    #   close_modal
    #   close_modal button_text: "Close"
    def close_modal(modal_id: "#modal", button_text: "Cancel")
      click_on button_text
      wait_for_modal_to_close modal_id: modal_id
    end

    # Fill and submit a form within a modal
    #
    # @param modal_id [String] The CSS selector for the modal (default: "#modal")
    # @param button_text [String] The submit button text
    # @yield Block to fill in the form fields
    #
    # @example
    #   submit_modal_form(button_text: "Create User") do
    #     fill_in "Email", with: "test@example.com"
    #     select "English", from: "Language"
    #   end
    def submit_modal_form(modal_id: "#modal", button_text: nil, &block)
      within modal_id do
        block.call if block
        click_button button_text if button_text
      end
    end
  end
end
