class UsersController < ApplicationController
  expose :user

  def new
  end

  def create
    if user.save
      cookies.signed.permanent[:auth_token] = user.auth_token
      redirect_to root_url, notice: "Signed up"
    else
      render :new
    end
  end
end
