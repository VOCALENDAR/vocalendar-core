class SettingsController < ApplicationController
  load_and_authorize_resource

  def index
    respond_with @settings
  end

  def destroy
    @setting.destroy
    respond_with @setting
  end
end
