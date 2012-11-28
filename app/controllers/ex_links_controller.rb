class ExLinksController < ApplicationController
  load_and_authorize_resource :except => :redirect

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

  def redirect
    @ex_link = ExLink.find params[:short_id].to_s.to_i(36)
    redirect_to @ex_link.uri
  end
end
