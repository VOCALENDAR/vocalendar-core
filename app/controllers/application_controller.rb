class ApplicationController < ActionController::Base
  include VocalendarCore::Utils

  protect_from_forgery
  self.responder = AppResponder
  respond_to :html, :xml, :json

end
