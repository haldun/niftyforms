class FormsController < ApplicationController
  respond_to :html, :json

  before_filter :authenticate_user!

  expose(:forms) { Form.where(user_id: current_user.id) }
  expose(:form)

  def index
    respond_with forms
  end

  def show
    respond_with form
  end

  def new
  end

  def edit
  end

  def preview
  end

  def create
    form.user_id = current_user.id
    if form.save
      flash.notice = "Form is created"
    end
    respond_with form
  end

  def update
    if form.save
      flash.notice = "Form is updated"
    end
    respond_with form
  end

  def destroy
    form.destroy
    respond_with form
  end
end
