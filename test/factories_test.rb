# frozen_string_literal: true

require "test_helper"

class FactoriesTest < ActiveSupport::TestCase
  it "all factories and traits are valid" do
    FactoryBot.lint(traits: true)
    assert true
  end
end
