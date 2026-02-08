# frozen_string_literal: true

require "application_system_test_case"

module Admin
  module Users
    class IndexTest < ApplicationSystemTestCase
      setup do
        @admin = create(:user, :admin)
        @regular_user = create(:user)
      end

      # Authorization Tests
      it "non-admin cannot access admin users index" do
        sign_in_as @regular_user, visit_path: admin_users_path

        assert_unauthorized
        assert_current_path root_path
      end

      it "non-admin cannot access new user page" do
        sign_in_as @regular_user, visit_path: new_admin_user_path

        assert_unauthorized
      end

      it "non-authenticated user is redirected to sign in" do
        visit admin_users_path

        assert_requires_sign_in
      end

      # Index Page Tests
      it "admin can view users index" do
        sign_in_as @admin, visit_path: admin_users_path

        assert_selector "h1", text: "Users"
        assert_accessible
      end

      it "admin can see list of users" do
        create_list(:user, 3)

        sign_in_as @admin, visit_path: admin_users_path
        wait_for_page_load content: @admin.email

        within "table" do
          assert_selector "tbody tr", count: 5 # 2 from setup + 3 created
        end
        assert_accessible
      end

      # Infinite Loading Tests
      it "admin can load more users with infinite scroll" do
        create_list(:user, 6) # With limit of 3, this gives us 2+ pages (8 total with setup users)

        sign_in_as @admin, visit_path: admin_users_path

        # Check initial load shows first page (3 items per page in test env)
        wait_for_page_load selector: "tbody tr"

        # Scroll to bottom to trigger loading
        page.execute_script("window.scrollTo(0, document.body.scrollHeight)")

        # Wait for more content to load (should now show more than initial page)
        assert_selector "tbody tr", minimum: 4

        assert_accessible
      end

      # Combined workflow tests
      it "admin can perform full CRUD workflow" do
        sign_in_as @admin, visit_path: admin_users_path
        assert_selector "h1", text: "Users"

        # Create
        open_modal "Add User"
        submit_modal_form(button_text: "Create User") do
          fill_in "Email", with: "workflow@example.com"
          select "English", from: "Language"
          select "User", from: "Role"
        end

        wait_for_turbo_stream modal_id: "#modal"
        assert_text "workflow@example.com"

        # Update
        user = User.find_by!(email: "workflow@example.com")
        open_edit_modal_for user.id

        submit_modal_form(button_text: "Update User") do
          fill_in "Email", with: "updated_workflow@example.com"
        end

        wait_for_turbo_stream modal_id: "#modal"
        assert_text "updated_workflow@example.com"

        # Delete
        user.reload
        delete_record user.id

        refute_text "updated_workflow@example.com"

        assert_accessible
      end
    end
  end
end
