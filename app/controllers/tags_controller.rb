class TagsController < ApplicationController
  include VocalendarCore::HistoryUtils::Controller
  load_resource except: [:create]

  def index
    @tags = @tags.includes(:link).references(:link)
    @tags = @tags.order("name").page(params[:page]).per(50)
    @tag_count = Tag.includes(:events).group(:tag_id).references(:events).count(:event_id)
      
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
    @tag = Tag.new(create_params)
    @tag.save
    @tag.errors.empty? and add_history
    respond_with(@tag)
  end

  def update
    @tag.update_attributes(update_params)
    @tag.errors.empty? and add_history
    respond_with(@tag)
  end

  def destroy
    @tag.destroy
    add_history
    respond_with(@tag)
  end

  private
  def update_params
    params.require(:tag).permit(:link_uri, :hidden)
  end

  def create_params
    params.require(:tag).permit(:name, :link_uri, :hidden)
  end

end


