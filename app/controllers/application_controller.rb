class ApplicationController < ActionController::Base
  class VcResponder < ActionController::Responder
    include Responders::FlashResponder
    def respond
      resource.respond_to?(:errors) && resource.try(:errors).try(:any?) and
        Rails.logger.debug "Resource error: #{resource.errors.pretty_inspect}"
      super
    end
  end

  class ProcessError < StandardError
    def initialize(msg, status = 404)
      @status = status
      super(msg)
    end
    attr_accessor :status
  end

  protect_from_forgery
  self.responder = VcResponder
  respond_to :html, :xml, :json

  rescue_from ProcessError, :with => :render_proc_error
  rescue_from ActiveRecord::RecordNotFound, :with => :render_ar_error
  rescue_from CanCan::AccessDenied, :with => :render_cancan_error

  before_filter :check_admin_oauth_scope
  before_filter :set_common_vars
  before_filter :set_debug_mode
  before_filter :post_google_analystics

  private

  @@log_level = { debug: Logger::DEBUG,
                  info:  Logger::INFO,
                  warn:  Logger::WARN,
                  error: Logger::ERROR,
                  fatal: Logger::FATAL
  } 
  # デバッグモード
  def set_debug_mode
    if params[:debug]
      Rails.logger.level = Logger::DEBUG
    else
      if config.log_level
        Rails.logger.level = @@log_level[config.log_level]
        return
      end
      Rails.env.production? and Rails.logger.level = Logger::INFO
      
    end
  end
  
  def post_google_analystics
  
    proxy_addr = "proxy.jfe-systems.com"
    proxy_port = "8080"
  
    uri = URI.parse("http://www.google-analytics.com/collect")
    Net::HTTP::Proxy(proxy_addr, proxy_port).start(uri.host, uri.port){ |http|
      header = {
        "User-Agent" => request.user_agent
      }
      version = 1
      tracking_id = "UA-46391605-1"
      type = "pageview"
      document_path = CGI.escape(request.fullpath)
  
      body = "v=#{version}&tid=#{tracking_id}&t=#{type}&dp=#{document_path}&cid=core"
  
      response = http.post(uri.path, body, header)
    }
  
  end


  def set_common_vars
    @current_controller_name = controller_name
    @current_action_name     = action_name
  end

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
    logger.error "Process error [#{request.path}]: (#{e.status}) #{e.message}"
    render_error :message => e.message, :status => e.status
  end

  def render_ar_error(e)
    logger.error "RecordNotFound [#{request.path}]: (404) #{e.message}"
    render_error :message => e.message, :status => 404
  end

  def render_cancan_error(e)
    if user_signed_in?
      logger.error "Forbidden [#{request.path}]: (403) #{e.message}"
      render_error :message => e.message, :status => 403
    else
      session[:"user_return_to"] = request.fullpath
      redirect_to new_user_session_path
    end
  end

  def check_admin_oauth_scope
    controller_name == 'sessions' and return
    controller_name == 'omniauth_callbacks' and return
    user_signed_in? or return
    current_user.admin? or return
    scope = current_user.google_auth_scope.to_s
    cs    = "https://www.googleapis.com/auth/calendar"
    scope.include?("#{cs}.readonly") && scope.include?(cs) and return true
    redirect_to user_omniauth_authorize_path(:provider => :google_oauth2, :scope => 'userinfo.email,userinfo.profile,calendar,calendar.readonly')
    false
  end
end
