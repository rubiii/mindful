# frozen_string_literal: true

require "application_system_test_case"

module Admin
  module Users
    class FilterTest < ApplicationSystemTestCase
      setup do
        @admin = create(:user, :admin)
        @user = create(:user)
      end

      it "admin can filter users by active state" do
        pending_user = create(:user, email: "pending@example.com", invitation_sent_at: Time.current)

        sign_in_as @admin, visit_path: admin_users_path

        assert_text pending_user.email
        assert_text @user.email

        # Filter by invitation_pending
        select "Invitation pending", from: "account_state"

        # Wait for Turbo Frame to update
        assert_text pending_user.email
        refute_text @user.email
        assert_accessible
      end

      it "admin can clear filter to see all users" do
        invited_user = create(:user, invitation_sent_at: Time.current)

        sign_in_as @admin, visit_path: admin_users_path

        assert_text invited_user.email
        assert_text @user.email

        select "Invitation pending", from: "account_state"

        # Wait for filter to apply - should only show invitation pending user
        assert_text invited_user.email
        refute_text @user.email

        # Clear filter
        select "All", from: "account_state"

        # Wait for filter to clear - with pagination limit of 3, we may not see all 4 users
        # Just verify the filter was cleared by checking that at least the admin user is visible
        assert_text @admin.email
        assert_accessible
      end
    end
  end
end
