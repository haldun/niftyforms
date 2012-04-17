class PostsController < ApplicationController
  respond_to :html, :json

  expose(:form) { Form.find(params[:form_id]) }
  expose(:posts) { form.posts }
  expose(:post)

  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end
end
