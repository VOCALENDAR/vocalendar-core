class ApplicationController < ActionController::Base
  class ProcessError < StandardError
    def initialize(msg, status = 404)
      @status = status
      super(msg)
    end
    attr_accessor :status
  end

  protect_from_forgery
  self.responder = AppResponder
  respond_to :html, :xml, :json

  rescue_from ProcessError, :with => :render_proc_error
  rescue_from ActiveRecord::RecordNotFound, :with => :render_ar_error
  rescue_from CanCan::AccessDenied, :with => :render_cancan_error

  private
  def add_flash_msg(level, msg)
    flash[level] ||= []
    flash[level] << msg
  end

  def add_cur_flash_msg(level, msg)
    flash.now[level] ||= []
    flash.now[level] << msg
  end

  def raise_error_400(msg)
    raise ProcessError.new(msg, 400)
  end

  def raise_error_403(msg)
    raise ProcessError.new(msg, 403)
  end

  def raise_error_404(msg)
    raise ProcessError.new(msg, 404)
  end

  def render_error(opt)
    @message = opt[:message]
    opt[:status] ||= 400
    opt[:template] ||= "misc/error_#{opt[:status]}"
    respond_to do |format|
      format.html { render opt }
      format.json {
        opt.delete :template
        render :json => opt, :status => opt[:status]
      }
    end
  end

  def render_proc_error(e)
    render_error :message => e.message, :status => e.status
  end

  def render_ar_error(e)
    render_error :message => e.message, :status => 404
  end

  def render_cancan_error(e)
    render_error :message => e.message, :status => 403
  end

end
