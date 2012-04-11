class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by_auth_token(cookies.signed[:auth_token]) if cookies[:auth_token]
  end

  def authenticate_user!
    if current_user.nil?
      session[:return_to_url] = request.url
      redirect_to login_url
    end
  end

  def redirect_back_or_to(url, flash_hash={})
    redirect_to(session[:return_to_url] || url, flash: flash_hash)
  end
end
