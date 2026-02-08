# frozen_string_literal: true

require "application_system_test_case"

class HomeTest < ApplicationSystemTestCase
  it "visiting the index redirects to sign in, then allows access" do
    user = create(:user)

    # Visit the root path
    visit root_url

    # Assert we are redirected to the sign-in page
    assert_requires_sign_in

    # Check accessibility of the sign-in page
    assert_accessible

    # Sign in as the user
    sign_in_as user

    # Assert we are now on the home page
    within("main") do
      assert_selector "h1", text: "Home"
    end

    # Check accessibility of the home page
    assert_accessible
  end
end
