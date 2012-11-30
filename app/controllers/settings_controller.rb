class SettingsController < ApplicationController
  load_resource :except => :set
  authorize_resource

  def index
    # create default names...
    all_settings = Setting.all
    %w(amazon_tracking_id).each do |name|
      all_settings.has_key?(name) or
        Setting.__send__("#{name}=", nil)
    end

    respond_with @settings
  end

  def set
    name = params[:name]
    unless name.blank?
      Setting.__send__ "#{name}=", params[:value]
      add_flash_msg :notice, "Setting #{name} has been updated successfully."
    end
    redirect_to settings_path
  end

  def destroy
    @setting.destroy
    respond_with @setting
  end
end
