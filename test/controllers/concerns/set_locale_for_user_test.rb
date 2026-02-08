# frozen_string_literal: true

require "test_helper"

class SetLocaleForUserTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Disable parallelization to avoid I18n.locale conflicts between workers
  parallelize(workers: 1)

  setup do
    I18n.locale = I18n.default_locale
  end

  teardown do
    I18n.locale = I18n.default_locale
  end

  it "uses params locale when provided" do
    user = create(:user, locale: "de")
    sign_in user

    assert_equal "de", I18n.locale.to_s

    get root_path, params: { locale: "en" }

    assert_equal "en", I18n.locale.to_s
  end

  it "uses current user locale when params locale not provided" do
    user = create(:user, locale: "en")
    sign_in user

    get root_path

    assert_equal "en", I18n.locale.to_s
  end

  it "uses browser locale when user not signed in and valid locale in header" do
    get root_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "de-DE,de;q=0.9,en;q=0.8" }

    assert_equal "de", I18n.locale.to_s
  end

  it "uses default locale when no other locale available" do
    get root_path

    assert_equal I18n.default_locale.to_s, I18n.locale.to_s
  end

  it "params locale takes precedence over user locale" do
    user = create(:user, locale: "de")
    sign_in user

    get root_path, params: { locale: "en" }

    assert_equal "en", I18n.locale.to_s
  end

  it "user locale takes precedence over browser locale" do
    user = create(:user, locale: "en")
    sign_in user

    get root_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "de-DE,de;q=0.9" }

    assert_equal "en", I18n.locale.to_s
  end

  it "browser locale takes precedence over default locale" do
    get root_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "de-DE,de;q=0.9" }

    assert_equal "de", I18n.locale.to_s
  end

  it "ignores invalid locale in ACCEPT_LANGUAGE header" do
    get root_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "fr-FR,fr;q=0.9" }

    assert_equal I18n.default_locale.to_s, I18n.locale.to_s
  end
end
