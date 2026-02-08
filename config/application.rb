# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mindful
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Enable Rack::Attack middleware
    config.middleware.use Rack::Attack

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.eager_load_paths << Rails.root.join("extras")

    # Default to Berlin time zone.
    config.time_zone = "Berlin"

    # Load configuration from config/app.yml into `Rails.configuration.app`.
    config.app = config_for(:app)

    # Configure I18n.
    config.i18n.default_locale = :de
    config.i18n.fallbacks = [ :en ]
    config.i18n.available_locales = [ :de, :en ]
    config.i18n.load_path += Dir[config.root.join("config", "locales", "**", "*.yml")]

    # Prevent Rails from wrapping error fields in an extra div which breaks Bulma's layout
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag.html_safe }

    # Configure Active Job queue adapter
    config.active_job.queue_adapter = :good_job
  end
end
