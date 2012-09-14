class TagsController < ApplicationController
  def index
    @tags = Tag.paginate(:page => params[:page], :per_page => 50)
    respond_with(@tags)
  end

  def show
    @tag = Tag.find(params[:id])
    respond_with(@tag)
  end

  def new
    @tag = Tag.new
    respond_with(@tag)
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def create
    @tag = Tag.new(params[:tag])
    @tag.save
    respond_with(@tag)
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
    respond_with(@tag)
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    respond_with(@tag)
  end
end
