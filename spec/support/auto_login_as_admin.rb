RSpec.configure do |config|
  google_email = "google-test-user@example.com"
  google_scope = 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/calendar.readonly'

  admin_user_valid_attrs = Proc.new {
    email = "test-admin-user-#{rand(10000)}@example.com"
    {
      :role              => :admin,
      :name              => 'Test Admin User',
      :email             => email,
      :google_account    => email,
      :google_auth_scope => google_scope,
      :google_auth_valid => true,
    }
  }

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = Hashie::Mash.new({
    'provider' => 'google_oauth2',
    'scope' => google_scope,
    'uid' => google_email,
    'info' => {'email' => google_email, 'name' => 'Test Admin User'},
    'credentials' => {
      'token' => '--test-atuh-token--',
      'refresh_token' => '--test-refresh-token--',
      'expires_at' => Time.now.to_i
    },
  })

  config.include Devise::TestHelpers, :type => :controller

  config.before(:each, :type => :view) do
    view.stub(:user_signed_in?).and_return(true)
    view.stub(:current_user).and_return User.create(admin_user_valid_attrs.call, :without_protection => true)
  end

  config.before(:each, :type => :controller) do
    sign_in User.create(admin_user_valid_attrs.call, :without_protection => true)
    subject.current_user
    subject.instance_eval {
      @current_ability = nil
    }
  end

  config.before(:all, :type => :request) do
    @session = Hashie::Mash.new({:google_oauth2_scope => google_scope})
    get user_omniauth_callback_path(:google_oauth2)
  end
end
