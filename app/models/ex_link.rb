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
      args += [q, q]
    end
    args.empty? and return
    where(["lower(uri) like ? or lower(title) like ?"].join(' or '), *args)
  }


  validates :uri,    :presence => true,   :uri => true
  validates :digest, :uniqueness => true

  @@remote_fetch_enabled = true
  @@htmlentities_coder = HTMLEntities.new

  class << self
    def scan(text)
      text.to_s.scan(%r{(?:https?://|www\.)[\x21-\x26\x2a-\x3b=\x3f-\x7e]+}).map { |uri| #"
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

  def uri=(v)
    unless new_record? && self[:uri] != v
      if Rails.configuration.active_record.mass_assignment_sanitizer == :strict
        raise ArgumentError.new("Cannot update URI. Create a new record.")
      else
        return nil
      end
    end
    self[:uri] = v
    self[:digest] = self.class.digest(v)
    begin
      set_type_and_remote_id
    rescue StandardError, URI::InvalidURIError, TimeoutError => e
      logger.debug "[ExLink##{id}] HTTP fech failed to getting title: #{e.message}"
    end
  end

  def detect_type_and_remote_id
    type = nil
    remote_id = nil
    begin
      uri = URI.parse(self.uri) 
    rescue URI::InvalidURIError
      return {type: nil, remote_id: nil}
    end
    case uri.host
    when %r{^(?:www\.)?amazon\.(?:co\.)?jp$}
      type = 'ExLink::Amazon'
      uri.path =~ %r{(?:dp|ASIN)/([^/]{4,})} and remote_id = $1
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

  def set_type_and_remote_id
    ti = detect_type_and_remote_id
    ti[:type] or return
    self[:type]      = ti[:type]
    self[:remote_id] = ti[:remote_id]
    title? and return
    @@remote_fetch_enabled or return
    t = get_remote_title and
      self[:title] = t
  end

  def update_type_and_remote_id
    set_type_and_remote_id
    save
  end

  def typename
    (type.to_s.split('::').last || 'Default').underscore
  end

  def update_title
    title? and return
    @@remote_fetch_enabled or return
    t = get_remote_title and
      update_attribute :title, t
  end

  def get_remote_title
    response = nil
    cur_uri = self.uri
    begin
      Timeout::timeout(3) {
        while cur_uri
          response = Faraday.get cur_uri
          cur_uri = nil
          response.status == 301 || response.status == 302 and
            cur_uri = response.headers["location"]
        end
      }
    rescue => e
      logger.error "[URI ##{id}] Remote title fetch error: #{e.message}"
      return nil
    end
    response.status == 200 or return nil
    body = response.body
    response.headers["content-type"] =~ /charset=([.a-z0-9_-]*)/i or
      body =~ /charset=["']?([a-z0-9._-]+?)(?=["'>\s])/i
    code = $1
    case code.to_s.downcase
    when 'shift', 'ms932', 'x-sjis'
      code = 'shift_jis'
    when 'x-euc', 'euc'
      code = 'euc-jp'
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

  class Amazon < ExLink
    include InjectCommonVars
    alias_attribute :asin, :remote_id
    alias_attribute :isbn, :remote_id
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
