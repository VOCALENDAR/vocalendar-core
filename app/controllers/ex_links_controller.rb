class ExLinksController < ApplicationController
  load_and_authorize_resource

  def index
    respond_with(@ex_links)
  end

  def show
    respond_with(@ex_link)
  end

  def new
    respond_with(@ex_link)
  end

  def edit
  end

  def create
    @ex_link.save
    respond_with(@ex_link)
  end

  def update
    @ex_link.update_attributes(params[:ex_link])
    respond_with(@ex_link)
  end

  def destroy
    @ex_link.destroy
    respond_with(@ex_link)
  end
end
