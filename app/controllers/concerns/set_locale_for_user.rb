# frozen_string_literal: true

# Sets the I18n locale for the current session.
module SetLocaleForUser
  extend ActiveSupport::Concern

  # Sets the I18n locale for the current session.
  def set_locale
    I18n.locale = params[:locale] ||
                  current_user&.locale ||
                  browser_locale ||
                  I18n.default_locale
  end

  # Returns the locale from ACCEPT-LANGUAGE header when it's valid.
  def browser_locale
    accept_language = request.env["HTTP_ACCEPT_LANGUAGE"]
    return unless accept_language

    locale = accept_language.scan(/^[a-z]{2}/).first
    locale if locale.in?(I18n.available_locales.map(&:to_s))
  end

  included do
    prepend_before_action :set_locale
  end
end
