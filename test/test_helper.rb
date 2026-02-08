# frozen_string_literal: true

# Start SimpleCov before loading Rails
require "simplecov"
SimpleCov.start "rails" do
  # Exclude files from coverage
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"

  # Groups for better organization
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
  add_group "Jobs", "app/jobs"
  add_group "Channels", "app/channels"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/spec"

# Load all support files
Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

module SpecDSL
  include Minitest::Spec::DSL

  alias_method :context, :describe
end

module ActiveSupport
  class TestCase
    extend SpecDSL

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include FactoryBot::Syntax::Methods

    # Add more helper methods to be used by all tests here...
  end
end

# Extend other test base classes with Spec DSL
ActionDispatch::IntegrationTest.extend(SpecDSL)
ActionView::TestCase.extend(SpecDSL)
ActionController::TestCase.extend(SpecDSL) if defined?(ActionController::TestCase)
