# frozen_string_literal: true

require "application_system_test_case"

module Admin
  module Users
    class UpdateTest < ApplicationSystemTestCase
      setup do
        @admin = create(:user, :admin)
        @regular_user = create(:user)
      end

      it "admin can open edit user modal" do
        user = create(:user, email: "editable@example.com")

        sign_in_as @admin, visit_path: admin_users_path

        open_edit_modal_for user.id

        within "#modal" do
          assert_selector "p", text: "Edit User"
          assert_field "Email", with: "editable@example.com"
        end
        assert_accessible
      end

      it "admin can update user email" do
        user = create(:user, email: "old@example.com")

        sign_in_as @admin, visit_path: admin_users_path

        open_edit_modal_for user.id

        submit_modal_form(button_text: "Update User") do
          fill_in "Email", with: "updated@example.com"
        end

        wait_for_turbo_stream success_message: "User was updated", modal_id: "#modal"
        assert_text "updated@example.com"
        refute_text "old@example.com"
        assert_accessible
      end

      it "admin can update user locale" do
        user = create(:user, locale: "en")

        sign_in_as @admin, visit_path: admin_users_path

        open_edit_modal_for user.id

        submit_modal_form(button_text: "Update User") do
          select "German", from: "Language"
        end

        wait_for_turbo_stream modal_id: "#modal"

        within "#user_#{user.id}" do
          assert_text "German"
        end
        assert_accessible
      end

      it "admin can update user role" do
        user = create(:user, role: :user)

        sign_in_as @admin, visit_path: admin_users_path

        open_edit_modal_for user.id

        submit_modal_form(button_text: "Update User") do
          select "Admin", from: "Role"
        end

        wait_for_turbo_stream modal_id: "#modal"

        within "#user_#{user.id}" do
          assert_text "Admin"
        end
        assert_accessible
      end

      it "updating user with invalid data shows errors" do
        user = create(:user, email: "valid@example.com")

        sign_in_as @admin, visit_path: admin_users_path

        open_edit_modal_for user.id

        submit_modal_form(button_text: "Update User") do
          fill_in "Email", with: "" # Invalid
        end

        # Form should stay open with validation error
        within "#modal" do
          assert_selector "p.modal-card-title", text: "Edit User"
        end
        assert_accessible
      end
    end
  end
end
