# frozen_string_literal: true

require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = create(:user, :admin)
    @regular_user = create(:user)
    @other_user = create(:user)
  end

  describe "#index?" do
    it "admin can view user index" do
      policy = UserPolicy.new(@admin, User)
      assert policy.index?
    end

    it "regular user cannot view user index" do
      policy = UserPolicy.new(@regular_user, User)
      assert_not policy.index?
    end
  end

  describe "#show?" do
    it "admin can show any user" do
      policy = UserPolicy.new(@admin, @other_user)
      assert policy.show?
    end

    it "regular user can show themselves" do
      policy = UserPolicy.new(@regular_user, @regular_user)
      assert policy.show?
    end

    it "regular user cannot show other users" do
      policy = UserPolicy.new(@regular_user, @other_user)
      assert_not policy.show?
    end
  end

  describe "#create?" do
    it "admin can create users" do
      policy = UserPolicy.new(@admin, User)
      assert policy.create?
    end

    it "regular user cannot create users" do
      policy = UserPolicy.new(@regular_user, User)
      assert_not policy.create?
    end
  end

  describe "#update?" do
    it "admin can update any user" do
      policy = UserPolicy.new(@admin, @other_user)
      assert policy.update?
    end

    it "regular user can update themselves" do
      policy = UserPolicy.new(@regular_user, @regular_user)
      assert policy.update?
    end

    it "regular user cannot update other users" do
      policy = UserPolicy.new(@regular_user, @other_user)
      assert_not policy.update?
    end
  end

  describe "#destroy?" do
    it "admin can destroy users" do
      policy = UserPolicy.new(@admin, @other_user)
      assert policy.destroy?
    end

    it "regular user cannot destroy users" do
      policy = UserPolicy.new(@regular_user, @other_user)
      assert_not policy.destroy?
    end

    it "regular user cannot destroy themselves" do
      policy = UserPolicy.new(@regular_user, @regular_user)
      assert_not policy.destroy?
    end
  end

  describe "#permitted_attributes" do
    it "admin can modify email, locale, and role" do
      policy = UserPolicy.new(@admin, @other_user)
      assert_equal %i[email locale role], policy.permitted_attributes
    end

    it "regular user can only modify email and locale" do
      policy = UserPolicy.new(@regular_user, @regular_user)
      assert_equal %i[email locale], policy.permitted_attributes
    end
  end

  describe "Scope" do
    it "admin scope resolves to all users" do
      scope = UserPolicy::Scope.new(@admin, User).resolve
      assert_equal User.count, scope.count
      assert_includes scope, @regular_user
      assert_includes scope, @other_user
    end

    it "regular user scope resolves to only themselves" do
      scope = UserPolicy::Scope.new(@regular_user, User).resolve
      assert_equal 1, scope.count
      assert_includes scope, @regular_user
      assert_not_includes scope, @other_user
    end
  end
end
