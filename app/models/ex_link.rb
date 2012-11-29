# -*- encoding: utf-8 -*-
require 'htmlentities'

class ExLink < ActiveRecord::Base
  self.store_full_sti_class = true
  attr_accessible :title
  attr_accessible :uri, :if => :new_record?
  has_and_belongs_to_many :related_events, :class_name => 'Event'
  has_many :main_events, :foreign_key => :primary_link_id, :class_name => 'Event'
  has_many :tags,        :foreign_key => :primary_link_id
  has_many :accesses,    :class_name => 'ExLinkAccess', :dependent => :delete_all

  scope :search, lambda{ |query|
    args = []
    query.strip.split(/[　 \t\n\r]+/).each do |q|
      q.blank? and next
      q = "%#{q.downcase}%"
      args += [q, q, q]
    end
    args.empty? and return
    where(["lower(uri) like ? or lower(title) like ? or lower(endpoint_uri) like ?"].join(' or '), *args)
  }


  validates :uri,    :presence => true,   :uri => true
  validates :digest, :uniqueness => true

  @@remote_fetch_enabled = true
  @@htmlentities_coder = HTMLEntities.new

  class << self
    def scan(text)
      text.to_s.scan(%r{(?:https?://|www\.)[\x21-\x26\x2a-\x3b=\x3f-\x7e]+}).map { |uri| #"
        uri[0..3] != 'http' and uri = 'http://' + uri
        find_or_create_by_uri uri
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

    def events
      [main_events + related_events].uniq
    end

    def tags
      [main_tags + related_tags].uniq
    end

    def remote_fetch_enabled
      @@remote_fetch_enabled
    end

    def remote_fetch_enabled=(v)
      @@remote_fetch_enabled = v
    end
  end

  def access_count
    accesses.count(:id)
  end

  def short_id
    id.try(:to_s, 36)
  end

  def access_uri
    uri
  end

  def endpoint_uri!
    endpoint_uri? ? endpoint_uri : uri
  end

  def uri=(v)
    unless new_record? && self[:uri] != v
      if Rails.configuration.active_record.mass_assignment_sanitizer == :strict
        raise ArgumentError.new("Cannot update URI. Create a new record.")
      else
        return nil
      end
    end
    self[:uri] = @cur_uri = v
    self[:digest] = self.class.digest(v)
    begin
      set_attributes_by_uri
    rescue StandardError, URI::InvalidURIError, TimeoutError => e
      logger.debug "[ExLink##{id}] HTTP fech failed to getting title: #{e.message}"
    end
  end

  def detect_type_and_remote_id
    type = nil
    remote_id = nil
    begin
      uri = URI.parse(endpoint_uri!)
    rescue URI::InvalidURIError
      return {type: nil, remote_id: nil}
    end
    case uri.host
    when %r{^(?:www\.)?amazon\.(?:co\.)?jp$}
      type = 'ExLink::Amazon'
      uri.path =~ %r{(?:dp|ASIN)/([^/]{4,})}i and remote_id = $1
    when %r{\.?nicovideo\.jp$}
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

  def set_attributes_by_uri
    t = get_remote_title and
      self[:title] = t
    @cur_uri != self.uri and
      self[:endpoint_uri] = @cur_uri
    ti = detect_type_and_remote_id
    if ti[:type]
      self[:type]      = ti[:type]
      self[:remote_id] = ti[:remote_id]
    end
  end

  def update_attributes_by_uri
    set_attributes_by_uri
    save
  end

  def typename
    (type.to_s.split('::').last || 'Default').underscore
  end

  def get_remote_title
    @@remote_fetch_enabled or return nil
    response = nil
    @cur_uri = self.uri
    begin
      Timeout::timeout(5) {
        while true
          logger.debug "[URI ##{id}] Fetching remote content: #{@cur_uri}"
          response = Faraday.head @cur_uri
          if response.status == 301 || response.status == 302
            loc = response.headers["location"]
            if loc.blank?
              @cur_uri = nil
              return nil
            end
            if loc[0..3] != 'http'
              @cur_uri = URI::join(@cur_uri, loc).to_s
            else
              @cur_uri = loc
            end
            next
          end
          response.headers["content-type"].to_s.include?("text/html") or
            return nil
          response = Faraday.get @cur_uri
          break
        end
      }
    rescue => e
      logger.error "[URI ##{id}] Remote title fetch error: #{e.message}"
      @cur_uri = nil
      return nil
    end
    unless response.status == 200 || response.status == 206
      @cur_uri = nil
      return nil
    end
    body = response.body
    response.headers["content-type"] =~ /charset=([.a-z0-9_-]*)/i
    code = $1 || CharlockHolmes::EncodingDetector.detect(body)[:encoding]
    case code.to_s.downcase
    when 'shift', 'ms932', 'x-sjis', 'sjis', 'shift-jis'
      code = 'shift_jis'
    when 'x-euc', 'euc'
      code = 'euc-jp'
    when 'utf8', 'unicode'
      code = 'utf-8'
    end
    body =~ %r{<title>(.*?)</title>}m or return nil
    begin
      title = $1.strip
      @@htmlentities_coder.decode title.gsub(/\s+/, ' ').force_encoding(code || 'utf-8').encode('utf-8', :invalid => :replace)
    rescue => e
      logger.error "[URI ##{id}] Failed to convert remote title encoding: #{e.message} (#{uri} : #{title})"
      return nil
    end
  end

  module InjectCommonVars
    def self.included(base)
      def base.model_name; ExLink.model_name; end
    end
  end

  class Amazon < ExLink # Note: amazon means amazon.jp...
    include InjectCommonVars
    alias_attribute :asin, :remote_id
    alias_attribute :isbn, :remote_id

    def access_uri
      aid = Rails.configuration.amazon_tracking_id or return uri
      u = endpoint_uri!.gsub(%r{/[^/]+-22/|t(?:ag)?=[^=&;]+-22&?}, '')
      u << "#{u.include?("?") ? "&" : "?"}tag=#{aid}"
    end
  end

  class NicoVideo < ExLink
    include InjectCommonVars
    alias_attribute :video_id, :remote_id
  end

  class YouTube < ExLink
    include InjectCommonVars
    alias_attribute :video_id, :remote_id
  end

  class Twitter < ExLink
    include InjectCommonVars
    alias_attribute :user_id, :remote_id
  end
end
