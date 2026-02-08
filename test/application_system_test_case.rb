# frozen_string_literal: true

require "test_helper"
require "axe/matchers/be_axe_clean"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemTestHelpers
  # Determine which driver to use based on HEADLESS environment variable
  driver_name = ENV.fetch("HEADLESS", "true") == "true" ? :headless_chrome : :chrome

  driven_by :selenium, using: driver_name, screen_size: [ 1400, 1400 ] do |options|
    # Disable password manager and leak detection
    options.add_preference("profile.password_manager_leak_detection", false)
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)

    # Core stability arguments (required for CI/Docker environments)
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")

    # Hide automation indicators
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_argument("--disable-infobars")

    # Performance and consistency
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-background-timer-throttling")
    options.add_argument("--disable-backgrounding-occluded-windows")
    options.add_argument("--disable-renderer-backgrounding")

    # Disable unnecessary features
    options.add_argument("--disable-features=TranslateUI")
    options.add_argument("--disable-popup-blocking")

    # Ensure consistent window size
    options.add_argument("--window-size=1400,1400")
  end

  def assert_accessible
    matcher = Axe::Matchers::BeAxeClean.new
    assert matcher.matches?(page), matcher.failure_message
  end
end
