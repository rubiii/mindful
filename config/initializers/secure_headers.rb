# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  if Rails.env.production?
    config.cookies = {
      secure: true, # mark all cookies as "Secure"
      httponly: true, # mark all cookies as "HttpOnly"
      samesite: {
        lax: true # mark all cookies as SameSite=Lax
      }
    }
  else
    config.cookies = SecureHeaders::OPT_OUT
  end

  # HSTS
  if Rails.env.production?
    config.hsts = "max-age=#{1.year.to_i}"
  end

  # Standard headers
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w[origin-when-cross-origin strict-origin-when-cross-origin]

  # Content Security Policy
  config.csp = {
    preserve_schemes: true,
    default_src: %w['self' https:],
    base_uri: %w['self'],
    child_src: %w['self'],
    connect_src: %w['self' wss:], # wss: is needed for ActionCable / Hotwire
    font_src: %w['self' https: data:],
    form_action: %w['self'],
    frame_ancestors: %w['none'],
    img_src: %w['self' https: data:],
    manifest_src: %w['self'],
    media_src: %w['self'],
    object_src: %w['none'],
    # Note: 'unsafe-inline' is often required for importmaps and Turbo unless nonces are strictly configured.
    script_src: %w['self' https: 'unsafe-inline'],
    style_src: %w['self' https: 'unsafe-inline'],
    worker_src: %w['self'],
    upgrade_insecure_requests: Rails.env.production?
  }
end
