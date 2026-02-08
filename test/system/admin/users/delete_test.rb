# frozen_string_literal: true

require "application_system_test_case"

module Admin
  module Users
    class DeleteTest < ApplicationSystemTestCase
      setup do
        @admin = create(:user, :admin)
        @regular_user = create(:user)
      end

      it "admin can delete a user" do
        user = create(:user, email: "tobedeleted@example.com")

        sign_in_as @admin, visit_path: admin_users_path

        delete_record user.id, success_message: "User was deleted"

        # Now the user should be removed from the list
        refute_text "tobedeleted@example.com"
        assert_accessible
      end

      it "admin cannot delete themselves" do
        sign_in_as @admin, visit_path: admin_users_path

        within "#user_#{@admin.id}" do
          # Should not have delete button for self
          assert_no_link "Delete"
        end
        assert_accessible
      end

      it "deleting user updates the table without page reload" do
        user1 = create(:user)

        sign_in_as @admin, visit_path: admin_users_path

        # Count rows safely (should be 3: @admin, @regular_user, user1)
        initial_count = count_table_rows wait_for_content: @admin.email

        delete_record user1.id, success_message: "User was deleted"

        # Table should update without reload
        assert_selector "tbody tr", count: initial_count - 1
        refute_text user1.email
        assert_text @regular_user.email
        assert_accessible
      end
    end
  end
end
