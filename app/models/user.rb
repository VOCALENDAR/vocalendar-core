class User < ActiveRecord::Base
  devise :trackable, :omniauthable

  enum_attr :role, %w(admin editor)
  attr_accessible :name, :email
  attr_accessible :name, :email, :role, :as => :admin

  validates :twitter_uid, :uniqueness => true, :allow_nil => true
  validates :google_account, :uniqueness => true, :allow_nil => true
  validates :email, :uniqueness => true, :allow_nil => true

  class << self
    def find_for_google_oauth2(auth, current_user = nil)
      !auth || !auth.uid and return nil
      u = current_user || find_or_initialize_by_google_account(auth.uid)
      c = auth["credentials"]
      u.assign_attributes({
        :google_auth_token       => c.token,
        :google_refresh_token    => c.refresh_token,
        :google_token_expires_at => Time.at(c.expires_at).to_datetime,
        :google_token_issued_at  => DateTime.now,
        :google_auth_valid       => true,
      }, :without_protection => true)
      u.email.blank? and u.email = auth["info"]["email"]
      u.name.blank?  and u.name  = auth["info"]["email"]
      u.auto_created = u.new_record?
      u.role = count < 1 ? :admin : nil
      u.save!
      u.adhoc_update_editor_role_by_calendar_membership_info
      u
    end

    def find_for_twitter(auth, current_user = nil)
      !auth || !auth.uid and return nil
      u = current_user || find_or_initialize_by_twitter_uid(auth.uid)
      u.assign_attributes({
        :twitter_name   => auth["info"]["name"],
        :twitter_nick   => auth["info"]["nickname"],
        :twitter_token  => auth["credentials"]["token"],
        :twitter_secret => auth["credentials"]["secret"],
        :twitter_token_issued_at => DateTime.now,
        :twitter_auth_valid => true,
      }, :without_protection => true)
      u.auto_created = u.new_record?
      u.name.blank? and u.name = auth["info"]["name"]
      u.role = count < 1 ? :admin : nil
      u.save!
      u
    end
  end

  def initalize
    super
    @auto_created = false
  end
  attr_accessor :auto_created

  def auto_created?; !!@auto_created; end

  def provider
    !self[:google_account].blank? ? :google_oauth2 : !self[:twitter_uid].blank? ? :twitter : nil
  end

  def admin?
    self[:role].to_s == 'admin'
  end

  def editor?
    admin? || self[:role].to_s == 'editor'
  end

  # TODO: FIX this function more flexisible...
  def adhoc_update_editor_role_by_calendar_membership_info
    admin? and return
    # TODO: REMOVE HARD-CODED Calendar ID
    ret = gapi_request("calendar_list.list")
    if ret && ret.data.items.find {|c| c.id == "pcg8ct8ulj96ptvqhllgcc181o@group.calendar.google.com" }
      u.update_attribute :role, :editor
    else
      u.update_attribute :role, nil
    end
  end

  def update_gapi_client_token
    @gapi_client or return false
    auth = @gapi_client.authorization
    auth.expired? or return
    logger.debug "[User #{id}] Google API: access token has been expired, trying refresh..."
    begin
      auth.fetch_access_token!
    rescue Signet::AuthorizationError => e
      update_attribute :google_auth_valid, true
      raise e
    end
    c = auth.credentials
    self.assign_attributes!({
      :google_auth_token       => c.token,
      :google_refresh_token    => c.refresh_token,
      :google_token_expires_at => Time.at(c.expires_at).to_datetime,
      :google_token_issued_at  => DateTime.now,
      :google_auth_valid       => true,
    }, :without_protection => true)
    logger.debug "[User ##{id}] Google API: access token refresh success."
  end

  def gapi_client
    google_auth_valid? or return nil
    if @gapi_client
      update_gapi_client_token
      return @gapi_client
    end
    gac = Google::APIClient.new
    auth = gac.authorization
    auth.client_id     = Rails.configuration.google_client_id
    auth.client_secret = Rails.configuration.google_client_secret

    auth.update_token!({
      :access_token  => google_auth_token,
      :refresh_token => google_refresh_token,
      :expires_in    => google_token_expires_at.to_i - google_token_issued_at.to_i - 30, # -30 sec for early refresh...
      :issued_at     => google_token_issued_at,
    })
    @gapi_client = gac
    update_gapi_client_token
    gac
  end

  def gapi_request(method, params = {}, body = nil, opts = {})
    client = gapi_client or return nil
    opts = {:service  => ['calendar', 'v3']}.merge(opts)
    service = client.discovered_api *opts[:service]
    api_method = service
    method.to_s.split('.').each {|m| api_method = api_method.__send__(m) }
    greq = {
      :headers    => {'Content-Type' => 'application/json'},
      :api_method => api_method,
      :parameters => {}.merge(params),
    }
    body and greq[:body] = body
    greq_orig = greq.dup
    logger.debug "[User #{id}] Execute Google API request #{api_method.id}"
    result = client.execute(greq)
    if result.status == 401
      # Tring to reload token forcely to make sure.
      # However in ordinal case, this error is caused by revoking auth.
      # So google_auth_valid may be disabled in this operation.
      update_attribute :token_expires_at, Time.at(0)
      update_attribute :token_issued_at,  Time.at(0)
      update_gapi_client_token
      return gapi_request method, params, body
    elsif result.status < 200 || result.status >= 300
      msg = "Error on Google API request '#{method}': status=#{result.status}, request=#{greq_orig.inspect} response=#{result.body}"
      logger.error "[User #{id}] #{msg}"
      raise GoogleAPIError.new(result, msg)
    end
    logger.debug "[User #{id}] Google API request #{greq[:api_method].id} success (status=#{result.status})"
    result
  end
end
