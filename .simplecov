# frozen_string_literal: true

# SimpleCov configuration
# See https://github.com/simplecov-ruby/simplecov

SimpleCov.start "rails" do
  coverage_dir "coverage"

  # Filters
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/db/"

  # Groups
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
  add_group "Jobs", "app/jobs"

  # Track all files
  track_files "{app,lib}/**/*.rb"
end
