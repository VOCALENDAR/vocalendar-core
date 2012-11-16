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
      u.email.blank? && auth["info"]["email"] and u.email = auth.info.email
      u.auto_created = u.new_record?
      u.role = count < 1 ? :admin : nil
      if u.auto_created?
        # TODO: set user role by google calendar access info
      end
      u.save!
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
        :twitter_auth_valid => true,
      }, :without_protection => true)
      u.auto_created = u.new_record?
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
    admin || self[:role].to_s == 'editor'
  end
end
