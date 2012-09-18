# -*- coding: utf-8 -*-
class Event < ActiveRecord::Base
  default_scope order('start_datetime')
  has_many :uris, :autosave => true, :dependent => :destroy
  has_and_belongs_to_many :tags
  accepts_nested_attributes_for :uris

  attr_accessible :g_calendar_id, :description, :etag, :g_html_link,
    :location, :status, :summary, :g_color_id, :g_creator_email,
    :g_creator_display_name, :start_date, :start_datetime,
    :end_date, :end_datetime, :g_id, :recur_string, :recur_freq,
    :recur_count, :recur_until, :recur_interval, :recur_wday,
    :ical_uid, :tz_min, :country, :lang, :allday, :uris_attributes

  validates :g_id, :uniqueness => true, :allow_nil => true
  validates :etag, :presence => true
  validates :summary, :presence => true, :if => :active?
  validates :start_datetime, :presence => true, :if => :active?
  validates :end_datetime, :presence => true, :if => :active?
  validates :start_date, :presence => true, :if => :active?
  validates :end_date, :presence => true, :if => :active?
  validates :ical_uid, :presence => true, :if => :active?
  validates :recur_count, :numericality => {:only_integer => true}
  validates :recur_interval, :numericality => {:only_integer => true}
  validates :tz_min, :numericality => {:only_integer => true}
  validates :status, :inclusion => {:in => %w(confirmed cancelled)}

  before_validation :set_dummy_values_for_cancelled,
    :cascade_start_date, :cascade_end_datetime, :cascade_end_date,
    :mangle_tentative_status

  def cancelled?
    status == "cancelled"
  end
  alias_method :deleted?, :cancelled?

  def active?
    !cancelled?
  end

  def zone
    tz_min or return nil
    "#{tz_min < 0 ? '-' : '+'}#{"%02d" % (tz_min / 60).to_i.abs}:#{"%02d" % (tz_min % 60)}"
  end

  def zone=(v)
    v.blank? and tz_min = nil and return v
    unless v.to_s =~ /^([+-])([0-9][0-9]):([0-9][0-9])$/
      raise "Invalid TimeZone format: #{v}"
    end
    self[:tz_min] = ($1 == "-" ? -1 : 1) * ($2.to_i * 60 + $3.to_i)
    return v
  end

  def offset
    tz_min or return nil
    Rational.new(tz_min, 24*60)
  end

  def offset=(v)
    v.blank? && tz_min = nil and return v
    self[:tz_min] = (v * 24 * 60).to_i
    return v
  end

  def start_at
    allday? ? start_date : start_datetime
  end

  def end_at
    allday? ? end_date : end_datetime
  end

  def term_str
    s = start_at
    e = end_at
    year_fmt = ""
    s.year != e.year || s.year != Date.today.year and
      year_fmt = "%Y-"
    ret = s.strftime("#{year_fmt}%m-%d")
    allday? or ret << s.strftime(" %H:%M")
    appends = ""
    if s.year != e.year || s.month != e.month || s.day != e.day
      appends << e.strftime("#{year_fmt}%m-%d")
    end
    if !allday? && (!appends.blank? || s.hour != e.hour || s.min != e.min)
      !appends.blank? and appends << " "
      appends << e.strftime("%H:%M")
    end
    appends.blank? or ret += " - #{appends}"
    ret
  end

  def tag_names
    self.tags.map {|t| t.name }
  end

  def tag_names=(v)
    self.tags = v.map {|t| Tag.find_by_name(t) || Tag.create(:name => t) }
  end

  # Load attribute has from externel exchange format (e.g. google API)
  def load_exfmt(format, attrs, opts = {})
    self.respond_to? "load_exfmt_#{format}" or
      raise ArgumentError, "Exchange format #{format} is not supported"
    self.__send__ "load_exfmt_#{format}", attrs, opts
  end

  def load_exfmt_google_v3(attrs, opts = {})
    default_tz_min = opts[:default_tz_min] || (Time.now.to_datetime.offset * 60 * 24).to_i
    opts[:calendar_id].blank? and
      raise ArgumentError, "Need to specify :calendar_id as option"

    summary = attrs["summary"].to_s.strip
    tag_names = []
    while summary.sub!(/^【(.*?)】/, '')
      tag_names += $1.split(%r{[/／]+}).map {|t| t.strip }.compact
    end
    self.tag_names = tag_names

    self.attributes = {
      g_id: attrs.id,
      etag: attrs.etag,
      status: attrs.status,
      summary: summary.strip,
      description: attrs["description"],
      location: attrs["location"],
      g_html_link: attrs["htmlLink"],
      g_calendar_id: opts[:calendar_id],
      g_creator_email: attrs["creator"].try(:email),
      g_creator_display_name: attrs["creator"].try(:display_name),
      ical_uid: attrs["iCalUID"].to_s,
    }
    if attrs["start"]
      self.attributes = {
        start_datetime: attrs.start["dateTime"] || attrs.start.date.to_time.to_datetime,
        start_date: attrs.start["date"] || attrs.start.dateTime.to_date,
        end_datetime: attrs.end["dateTime"] || attrs.end.date.to_time.to_datetime,
        end_date: attrs.end["date"] || attrs.end.dateTime.to_date,
        tz_min: attrs.start["date"] ? default_tz_min : (attrs.start.dateTime.to_datetime.offset * 60 * 24).to_i,
        allday: !!attrs.start["date"],
        # TODO: recurrent support MUST!!!
        # TODO: support color_id support or drop 
      }
    end
  end

  def to_exfmt(format, opts = {})
    self.respond_to? "to_exfmt_#{format}" or
      raise ArgumentError, "Exchange format #{format} is not supported"
    self.__send__ "to_exfmt_#{format}", opts
  end

  def to_exfmt_google_v3(opts = {})
    tag_str = self.tag_names.join('/')
    tag_str.blank? or tag_str = "【#{tag_str}】 "
    summary = tag_str.to_s + self.summary
    {
      :iCalUID => self.ical_uid,
      :start => self.allday? ? {:date => self.start_date} : {:dateTime => self.start_datetime},
      :end => self.allday? ? {:date => self.end_date} : {:dateTime => self.end_datetime},
      :summary => summary,
      :description => self.description,
      :location => self.location,
      :status => self.status,
      # TODO: recurrence support!!
    }
  end

  private
  def cascade_start_date
    self[:start_date] ||= start_datetime.try(:to_date)
  end

  def cascade_end_datetime
    self[:end_datetime] ||= start_datetime
  end

  def cascade_end_date
    self[:end_date] ||= end_datetime.try(:to_date)
  end

  def mangle_tentative_status
    self.status == "tentative" or return true
    self[:status] = "confirmed"
  end

  def set_dummy_values_for_cancelled
    self.status == "cancelled" or return true
    self[:start_datetime] ||= DateTime.new(1970, 1, 1, 0, 0, 0, 0)
  end
end
