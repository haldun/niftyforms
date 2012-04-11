class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      return_to_url = session[:return_to_url]
      reset_session
      session[:return_to_url] = return_to_url
      if params[:remember_me]
        cookies.signed.permanent[:auth_token] = user.auth_token
      else
        cookies.signed[:auth_token] = user.auth_token
      end
      redirect_back_or_to root_url
    else
      flash.now.alert = "Wrong email or password"
      render :new
    end
  end

  def destroy
    reset_session
    cookies.delete :auth_token
    redirect_to root_url, :notice => "Logged out"
  end
end
