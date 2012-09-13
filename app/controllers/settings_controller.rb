class SettingsController < ApplicationController
  def index
    @settings = Setting.where(:thing_type => nil).order('var')
    respond_with @settings
  end

  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy
    respond_with @setting
  end
end
