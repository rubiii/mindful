# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :citext           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  locale                 :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("user"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invited_by            (invited_by_type,invited_by_id)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  context "validations" do
    it "valid user with valid locale" do
      user = build(:user, locale: "en")
      assert user.valid?
    end

    it "invalid user with invalid locale" do
      user = build(:user, locale: "invalid")
      assert_not user.valid?
      assert user.errors[:locale].present?
    end

    it "locale must be in available locales" do
      user = build(:user, locale: "fr")
      assert_not user.valid?
    end
  end

  context "role enum" do
    it "user role defaults to user" do
      user = create(:user)
      assert user.user?
      assert_not user.admin?
    end

    it "supports admin users" do
      user = create(:user, :admin)
      assert user.admin?
      assert_not user.user?
    end
  end

  describe "#account_state" do
    it "returns active for normal user" do
      user = create(:user)
      assert_equal :active, user.account_state
    end

    it "returns invitation_pending for invited user" do
      user = create(:user, invitation_token: "abc123", invitation_accepted_at: nil)
      assert_equal :invitation_pending, user.account_state
    end

    it "returns active for user who accepted invitation" do
      user = create(:user, invitation_token: nil, invitation_accepted_at: Time.current)
      assert_equal :active, user.account_state
    end

    it "returns active_password_reset for user with reset token" do
      user = create(:user, reset_password_token: "reset123")
      assert_equal :active_password_reset, user.account_state
    end

    it "prioritizes invitation_pending over password reset" do
      user = create(:user, invitation_token: "abc123", invitation_accepted_at: nil, reset_password_token: "reset123")
      assert_equal :invitation_pending, user.account_state
    end
  end

  describe ".not_pending_invitation" do
    it "includes users without invitation token" do
      user = create(:user, invitation_token: nil)
      assert_includes User.not_pending_invitation, user
    end

    it "includes users who accepted invitation" do
      user = create(:user, invitation_token: "abc123", invitation_accepted_at: Time.current)
      assert_includes User.not_pending_invitation, user
    end

    it "excludes users with pending invitation" do
      user = create(:user, invitation_token: "abc123", invitation_accepted_at: nil)
      assert_not_includes User.not_pending_invitation, user
    end
  end

  describe ".filter_by_account_state" do
    it "with invitation_pending returns only pending invitations" do
      pending_user = create(:user, invitation_token: "abc123", invitation_accepted_at: nil)
      active_user = create(:user)

      result = User.filter_by_account_state(:invitation_pending)
      assert_includes result, pending_user
      assert_not_includes result, active_user
    end

    it "with active_password_reset returns only users with reset token" do
      reset_user = create(:user, reset_password_token: "reset123")
      active_user = create(:user)

      result = User.filter_by_account_state(:active_password_reset)
      assert_includes result, reset_user
      assert_not_includes result, active_user
    end

    it "with active returns only active users" do
      active_user = create(:user)
      pending_user = create(:user, invitation_token: "abc123", invitation_accepted_at: nil)
      reset_user = create(:user, reset_password_token: "reset123")

      result = User.filter_by_account_state(:active)
      assert_includes result, active_user
      assert_not_includes result, pending_user
      assert_not_includes result, reset_user
    end

    it "with locked returns none" do
      create(:user)
      result = User.filter_by_account_state(:locked)
      assert_empty result
    end

    it "with confirmation_pending returns none" do
      create(:user)
      result = User.filter_by_account_state(:confirmation_pending)
      assert_empty result
    end

    it "with unknown state returns all users" do
      user = create(:user)
      result = User.filter_by_account_state(:unknown)
      assert_includes result, user
    end

    it "with blank string returns all users" do
      user = create(:user)
      result = User.filter_by_account_state("")
      assert_includes result, user
    end
  end

  describe ".available_locales" do
    it "returns array of locale strings" do
      locales = User.available_locales
      assert_kind_of Array, locales
      assert_includes locales, "en"
      assert_includes locales, "de"
    end
  end
end
