class ApplicationController < ActionController::Base
  include VocalendarCore::Utils

  protect_from_forgery
  self.responder = AppResponder
  respond_to :html, :xml, :json

  before_filter

  private
  def add_flash_msg(level, msg)
    flash[level] ||= []
    flash[level] << msg
  end

  def add_cur_flash_msg(level, msg)
    flash.now[level] ||= []
    flash.now[level] << msg
  end
end
