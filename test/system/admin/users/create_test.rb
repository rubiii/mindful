# frozen_string_literal: true

require "application_system_test_case"

module Admin
  module Users
    class CreateTest < ApplicationSystemTestCase
      setup do
        @admin = create(:user, :admin)
        @regular_user = create(:user)
      end

      it "admin can open new user modal" do
        sign_in_as @admin, visit_path: admin_users_path

        open_modal "Add User"

        within "#modal" do
          assert_text "Add User"
          assert_field "Email"
          assert_field "Language"
          assert_field "Role"
        end
        assert_accessible
      end

      it "admin can create a new user" do
        sign_in_as @admin, visit_path: admin_users_path

        open_modal "Add User"

        submit_modal_form(button_text: "Create User") do
          fill_in "Email", with: "newuser@example.com"
          select "English", from: "Language"
          select "User", from: "Role"
        end

        wait_for_turbo_stream success_message: "User was created", modal_id: "#modal"
        assert_text "newuser@example.com"
        assert_accessible
      end

      it "admin can create a new admin user" do
        sign_in_as @admin, visit_path: admin_users_path

        open_modal "Add User"

        submit_modal_form(button_text: "Create User") do
          fill_in "Email", with: "newadmin@example.com"
          select "English", from: "Language"
          select "Admin", from: "Role"
        end

        wait_for_turbo_stream success_message: "User was created", modal_id: "#modal"
        assert_text "newadmin@example.com"
        assert_accessible
      end

      it "creating user with invalid data shows errors" do
        sign_in_as @admin, visit_path: admin_users_path

        open_modal "Add User"

        submit_modal_form(button_text: "Create User") do
          fill_in "Email", with: "" # Invalid: blank email
        end

        # Form should stay open with validation error
        within "#modal" do
          assert_selector "p.modal-card-title", text: "Add User"
        end
        assert_accessible

        # Close modal to prevent test pollution
        close_modal
      end

      it "creating user with duplicate email shows error" do
        sign_in_as @admin, visit_path: admin_users_path
        create(:user, email: "duplicate@example.com")

        open_modal "Add User"

        submit_modal_form(button_text: "Create User") do
          fill_in "Email", with: "duplicate@example.com"
        end

        within "#modal" do
          assert_text "has already been taken"
        end
        assert_accessible

        # Close modal to prevent test pollution
        close_modal
      end
    end
  end
end
