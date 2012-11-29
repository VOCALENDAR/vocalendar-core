class TagsController < ApplicationController
  load_and_authorize_resource

  def index
    @tags = @tags.order("name").page(params[:page]).per(50)
    respond_with(@tags)
  end

  def show
    respond_with(@tag)
  end

  def new
    respond_with(@tag)
  end

  def edit
  end

  def create
    @tag.save
    pp @tag.errors
    respond_with(@tag)
  end

  def update
    @tag.update_attributes(params[:tag])
    respond_with(@tag)
  end

  def destroy
    @tag.destroy
    respond_with(@tag)
  end
end
