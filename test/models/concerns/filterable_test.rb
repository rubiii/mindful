# frozen_string_literal: true

require "test_helper"

class FilterableTest < ActiveSupport::TestCase
  # Create a test model that includes Filterable
  class TestUser < ApplicationRecord
    include Filterable

    self.table_name = "users"
    enum :role, { user: 0, admin: 1 }, default: :user

    scope :filter_by_email, ->(email) { where(email: email) }
    scope :filter_by_role, ->(role) { where(role: User.roles[role]) }
  end

  it "filter calls scope method for single filter" do
    user = create(:user, email: "test@example.com")
    create(:user, email: "other@example.com")

    result = TestUser.filter({ email: "test@example.com" })

    assert_equal 1, result.count
    assert_equal "test@example.com", result.first.email
  end

  it "filter calls multiple scope methods" do
    admin = create(:user, :admin, email: "admin@example.com")
    create(:user, email: "user@example.com")
    create(:user, :admin, email: "other-admin@example.com")

    result = TestUser.filter({ email: "admin@example.com", role: "admin" })

    assert_equal 1, result.count
    assert_equal "admin@example.com", result.first.email
    assert_equal true, result.first.admin?
  end

  it "filter ignores blank values" do
    create(:user)
    create(:user)

    result = TestUser.filter({ email: "", role: nil })

    assert_operator result.count, :>=, 2
  end

  it "filter returns all records when no filters provided" do
    create(:user)
    create(:user)

    result = TestUser.filter({})

    assert_operator result.count, :>=, 2
  end

  it "filter chains correctly with other scopes" do
    create(:user, :admin, email: "admin@example.com")
    create(:user, email: "user@example.com")

    result = TestUser.filter({ role: "admin" }).where(email: "admin@example.com")

    assert_equal 1, result.count
    assert_equal "admin@example.com", result.first.email
  end
end
