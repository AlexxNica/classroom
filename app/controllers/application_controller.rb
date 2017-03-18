# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  depends_on :authentication
  depends_on :errors
  depends_on :feature_flags

  def peek_enabled?
    logged_in? && current_user.staff?
  end

  private

  def not_found
    raise ActionController::RoutingError, 'Not Found'
  end
end
