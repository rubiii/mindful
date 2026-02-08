# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SetLocaleForUser
  include Pagy::Method
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery with: :exception, prepend: true

  # Only allow modern browsers supporting webp images, web push,
  # badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Invalidate etag for HTML responses when importmap changes.
  stale_when_importmap_changes

  before_action :authenticate_user!

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
