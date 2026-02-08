# frozen_string_literal: true

module SystemTestHelpers
  module AuthenticationHelpers
    # Sign in as a user and optionally visit a path
    #
    # @param user [User] The user to sign in as
    # @param visit_path [String, nil] Optional path to visit after signing in
    #
    # @example
    #   sign_in_as @admin
    #   sign_in_as @admin, visit_path: admin_users_path
    def sign_in_as(user, visit_path: nil)
      visit new_user_session_path

      # Ensure we're on the sign in page
      assert_selector "h1", text: "Log in"

      fill_in "Email", with: user.email
      fill_in "Password", with: "password"
      click_button "Log in"

      # Verify sign in was successful by checking for Sign out button
      assert_selector "button[aria-label='Sign out']"

      visit visit_path if visit_path
    end

    # Sign out the current user
    def sign_out
      find("button[aria-label='Sign out']").click
      assert_selector "h1", text: "Log in"
    end
  end
end
