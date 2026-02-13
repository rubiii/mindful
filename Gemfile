# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use pg as the database for Active Record
gem "pg", "~> 1.6"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache and Action Cable
gem "solid_cache"
gem "solid_cable"

# Multithreaded, Postgres-based, Active Job backend [https://github.com/bensheldon/good_job]
gem "good_job", "~> 4.13"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Use S3 for Active Storage (required for Hetzner Object Storage)
gem "aws-sdk-s3", require: false

# Rails form library [https://github.com/heartcombo/simple_form]
gem "simple_form", "~> 5.4"

# Agnostic pagination in plain ruby [https://github.com/ddnexus/pagy]
gem "pagy", "~> 43.2"

# Rack middleware for blocking & throttling [https://github.com/rack/rack-attack]
gem "rack-attack"

# Manages application's security headers [https://github.com/twitter/secure_headers]
gem "secure_headers"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Loads environment variables from .env files [https://github.com/bkeepers/dotenv]
  gem "dotenv-rails"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # factory_bot is a fixtures replacement [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails"

  # Static analysis Static analysis for HTML+ERB templates [https://github.com/marcoroth/herb]
  gem "herb", require: false

  # Manage and find missing translations [https://github.com/glebm/i18n-tasks]
  gem "i18n-tasks", "~> 1.0"
end

group :development do
  # Live-reload for Hotwire applications [https://github.com/hotwired/spark]
  gem "hotwire-spark"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Preview emails in the browser [https://github.com/fgrehm/letter_opener_web]
  gem "letter_opener_web"

  # Better error pages with REPL [https://github.com/BetterErrors/better_errors]
  gem "better_errors"
  gem "binding_of_caller"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  # Ruby integration for axe-core, the accessibility testing engine [https://github.com/dequelabs/axe-core-gems]
  gem "axe-core-capybara"

  # Code coverage analysis [https://github.com/simplecov-ruby/simplecov]
  gem "simplecov", require: false
end

# Flexible authentication solution for Rails with Warden [https://github.com/heartcombo/devise]
gem "devise", "~> 5.0"
gem "devise_invitable", "~> 2.0"

# Ruby authorization system [https://github.com/varvet/pundit]
gem "pundit"

gem "annotaterb", group: :development
