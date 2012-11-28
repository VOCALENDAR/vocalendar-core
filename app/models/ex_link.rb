class ExLink < ActiveRecord::Base
  self.store_full_sti_class = true
  attr_accessible :name, :uri
  has_and_belongs_to_many :events
  has_and_belongs_to_many :tags

  validates :uri,  :presence => true, :uri => true

  class << self
    def scan(text)
      text.scan(%r{(?:https?://|www\.)[^\s\x00-\x20()<>"'`\x7f]+}).map { |uri| #"
        uri[0..3] != 'http' and uri = 'http://' + uri
        find_or_initialize_by_uri uri
      }.select {|l| l.valid? }
    end

    def digest(uri)
      Digest::SHA1.hexdigest(uri)
    end

    def find_by_uri(uri)
      find_by_digest(digest(uri))
    end

    def find_by_uri!(uri)
      find_by_digest!(digest(uri))
    end

    def find_or_create_by_uri(uri)
      find_or_create_by_digest(digest(uri), uri: uri)
    end

    def find_or_initialize_by_uri(uri)
      find_or_initialize_by_digest(digest(uri), uri: uri)
    end
  end

  def short_id
    id.try(:to_s, 36)
  end

  def uri=(v)
    self[:uri] = v
    self[:digest] = self.class.digest(v)
    update_type_and_remote_id rescue URI::InvalidURIError
  end

  def detect_type_and_remote_id
    type = nil
    remote_id = nil
    uri = URI.parse(self.uri) 
    case uri.host
    when %r{^(?:www\.)?amazon\.(?:co\.)?jp$}
      type = 'ExLink::Amazon'
      uri.path =~ %r{(?:dp|ASIN)/([^/]{4,})} and remote_id = $1
    when %r{^(?:www\.)?nicovideo\.jp/}
      type = 'ExLink::NicoVideo'
      uri.path =~ %r{^/watch/([^/]+)} and remote_id = $1
    when %r{^(?:www\.)?youtube\.(?:com|[a-z][a-z])$/}
      type = 'ExLink::YouTube'
      uri.query =~ %r{v=([^&;]+)} and remote_id = $1
    when %r{^(?:www\.)?twitter\.(?:com|[a-z][a-z])}
      type = 'ExLink::Twitter'
      uri.path =~ %r{^/([^/]+)} ||
        uri.fragment =~ %r{^!/([^/]+)} and
        remote_id = $1
    end
    {type: type, remote_id: remote_id}
  end

  def update_type_and_remote_id
    ti = detect_type_and_remote_id
    ti[:type] or return
    self[:type]      = ti[:type]
    self[:remote_id] = ti[:remote_id]
  end

  def typename
    (type.split('::').last || 'Default').underscore
  end

  class Amazon < ExLink
    alias_attribute :asin, :remote_id
    alias_attribute :isbn, :remote_id
  end

  class NicoVideo < ExLink
    alias_attribute :video_id, :remote_id
  end

  class YouTube < ExLink
    alias_attribute :video_id, :remote_id
  end

  class Twitter < ExLink
    alias_attribute :video_id, :remote_id
  end
end
