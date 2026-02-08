# frozen_string_literal: true

module SystemTestHelpers
  module CrudHelpers
    # Open edit modal for a specific record
    #
    # @param record_id [Integer] The record ID
    # @param record_type [String] The record type (default: "user")
    # @param button_text [String] The edit button text (default: "Edit")
    #
    # @example
    #   open_edit_modal_for user.id
    #   open_edit_modal_for post.id, record_type: "post"
    def open_edit_modal_for(record_id, record_type: "user", button_text: "Edit")
      within "##{record_type}_#{record_id}" do
        click_on button_text
      end
      assert_selector "#modal .modal.is-active"
    end

    # Delete a record with confirmation
    #
    # @param record_id [Integer] The record ID
    # @param record_type [String] The record type (default: "user")
    # @param button_text [String] The delete button text (default: "Delete")
    # @param success_message [String, nil] Optional success message to wait for
    #
    # @example
    #   delete_record user.id, success_message: "User was deleted"
    def delete_record(record_id, record_type: "user", button_text: "Delete", success_message: nil)
      within "##{record_type}_#{record_id}" do
        click_on button_text
      end
      confirm_action
      wait_for_turbo_stream(success_message: success_message) if success_message
    end
  end
end
