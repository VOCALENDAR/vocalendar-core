RSpec.configure do |config|
  google_email = 'google-test-user@example.com'

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = Hashie::Mash.new({
    'provider' => 'google_oauth2',
    'uid' => google_email,
    'info' => {'email' => google_email },
    'credentials' => {
      'token' => '--test-atuh-token--',
      'refresh_token' => '--test-refresh-token--',
      'expires_at' => Time.now.to_i
    },
  })

  config.include Devise::TestHelpers, :type => :controller

  config.before(:each, :type => :view) do
    view.stub(:user_signed_in?).and_return(true)
    view.stub(:current_user).and_return User.create({:role => :admin}, :as => :admin)
  end

  config.before(:each, :type => :controller) do
    sign_in User.create({:role => :admin}, :as => :admin)
    subject.current_user
    subject.instance_eval {
      @current_ability = nil
    }
  end

  config.before(:all, :type => :request) do
    get user_omniauth_callback_path(:google_oauth2)
  end
end
