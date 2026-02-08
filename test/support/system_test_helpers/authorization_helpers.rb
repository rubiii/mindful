# frozen_string_literal: true

module SystemTestHelpers
  module AuthorizationHelpers
    # Assert that user is unauthorized and sees appropriate message
    #
    # @param expected_message [String] The expected unauthorized message
    #
    # @example
    #   assert_unauthorized
    #   assert_unauthorized "Access denied"
    def assert_unauthorized(expected_message: "You are not authorized to perform this action")
      assert_text expected_message
    end

    # Assert that user is redirected to sign in page
    #
    # @example
    #   assert_requires_sign_in
    def assert_requires_sign_in
      assert_selector "h1", text: "Log in"
      assert_current_path new_user_session_path
    end
  end
end
