class FormsController < ApplicationController
  respond_to :html, :json

  before_filter :authenticate_user!

  expose(:forms) { Form.where(user_id: current_user.id) }
  expose(:form)

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    form.user_id = current_user.id
    form.save
    respond_with form
  end

  def update
  end

  def destroy
  end
end
