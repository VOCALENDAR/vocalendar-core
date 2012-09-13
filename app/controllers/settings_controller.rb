class SettingsController < ApplicationController
  def index
    @settings = Setting.where(:thing_type => nil).order('var')
    respond_with @settings
  end

  def update
  end
end
