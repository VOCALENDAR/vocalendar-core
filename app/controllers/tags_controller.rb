class TagsController < ApplicationController
  include VocalendarCore::HistoryUtils::Controller
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
    @tag.errors.empty? and add_history
    respond_with(@tag)
  end

  def update
    @tag.update_attributes(params[:tag])
    @tag.errors.empty? and add_history
    respond_with(@tag)
  end

  def destroy
    @tag.destroy
    add_history
    respond_with(@tag)
  end
end
