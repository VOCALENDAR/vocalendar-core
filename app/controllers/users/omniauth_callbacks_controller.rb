class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
    after_login_callback "Google"
  end

  def twitter
    @user = User.find_for_twitter(request.env["omniauth.auth"], current_user)
    after_login_callback "Twitter"
  end

  def after_omniauth_failure_path_for(resource)
    resource == :user and return new_user_session_path
    raise "Unknown new session path for resource #{resource}"
  end

  def after_sign_in_path_for(resource_or_scope)
    if User === resource_or_scope && resource_or_scope.auto_created?
      user_path(resource_or_scope)
    else
      super
    end
  end

  private
  def after_login_callback(kind)
    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      flash[:notice] = I18n.t "devise.omniauth_callbacks.failed", :kind => kind
      redirect_to new_session_path
    end
  end
end
