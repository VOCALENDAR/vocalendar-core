# -*- coding: utf-8 -*-
class Event < ActiveRecord::Base
  class ExtraTagContainer < Hash
    class TagContainer < Array
      def names_str
        names.join(' ')
      end
      
      def names_str=(v)
        self.names = v.strip.split(VocalendarCore::TagSeparateRegexp)
      end
      
      def names
        map {|t| t.try(:name) }.compact
      end
      
      def names=(v)
        self.clear
        [v].flatten.compact.map {|t| t.strip }.
          find_all {|t| !t.blank? }.each {|t|
          push Tag.find_or_create_by_name(t.gsub(/\s+/, '_'))
        }
      end
    end

    def initialize(event)
      super()
      @loaded = false
      @event = event
    end
    attr_accessor :event

    def loaded?
      @loaded
    end

    def load
      loaded? and return self
      @loaded = true
      clear
      @event.extra_tag_relations.each do |r|
        make_default(r.target_field) << r.tag
      end
      self
    end

    def save
      new_rels = []
      each do |field, tags|
        i = 1
        tags.each do |tag|
          new_rels << EventTagRelation.find_or_create_by_tag_id_and_event_id_and_target_field(tag.id, @event.id, field, :pos => i)
          new_rels.last.update_attribute :pos, i
          i += 1
        end
      end
      @event.extra_tag_relation_ids = new_rels.map {|r| r.id}
    end
    alias_method :save!, :save

    def []=(k, v)
      load
      tc = make_default(k).clear
      [v].flatten.compct.each {|t| tc << t }
    end

    def [](k)
      load
      make_default(k)
    end

    private
    def make_default(key)
      fetch(key.to_s) {
        store(key.to_s, TagContainer.new)
      }
    end
  end

  scope :active, where(:status => 'confirmed')
  scope :by_tag_ids, (lambda do |ids|
    joins(:all_tag_relations).where('event_tag_relations.tag_id' => ids)
  end)
  scope :by_tag_name, (lambda do |name|
    joins(:all_tags).where('tags.name' => name)
  end)
  scope :search, (lambda do |query|
    sqls = []
    args = []
    tag_ids = []
    query.strip.split(/[　 \t\n\r]+/).each do |q|
      q.blank? and next
      qw = "%#{query}%"
      args += [qw, qw]
      sqls << "lower(summary) like lower(?) or lower(description) like lower(?)"
      tag_ids << Tag.find_by_name(q).try(:id)
    end
    tag_ids.compact!
    unless tag_ids.empty?
      sqls <<  "event_tag_relations.tag_id IN (?)"
      args << tag_ids
    end
    sqls.empty? and return
    joins(:all_tag_relations).where(sqls.join(' or '), *args)
  end)

  tagrel_opts = {
    :class_name => 'EventTagRelation',
    :order => 'target_field, pos',
  }
  has_many :all_tag_relations,   tagrel_opts.merge(:dependent => :delete_all)
  has_many :main_tag_relations,  tagrel_opts.merge(:conditions => {:target_field => ""})
  has_many :extra_tag_relations, tagrel_opts.merge(:conditions => "target_field != ''")

  has_many :all_tags,  :through => :all_tag_relations, :source => :tag
  has_many :tags,      :through => :main_tag_relations
  
  has_one  :recurrent_parent, :class_name => 'Event',
    :primary_key => 'g_recurring_event_id', :foreign_key => 'g_id',
    :conditions => "g_id IS NOT NULL" # NOTE: ...any other way?
  has_many :recurrent_children, :class_name => 'Event',
    :foreign_key => 'g_recurring_event_id', :primary_key => 'g_id',
    :conditions => "g_recurring_event_id IS NOT NULL" # NOTE: ...any other way?

  has_many :histories, :class_name => 'History',
    :conditions => {:target => 'event'}, :foreign_key => 'target_id'

  has_one  :src_calendar, :class_name => 'Calendar',
    :foreign_key => 'external_id', :primary_key => 'g_calendar_id'
  has_many :dst_calendars, :class_name => 'Calendar', :through => :all_tags,
    :source => :calendars, :conditions => {'calendars.io_type' => 'dst'}

  has_many :uris, :autosave => true, :dependent => :destroy

  mount_uploader :image, EventImageUploader

  accepts_nested_attributes_for :uris
  attr_accessible :description, :location, :summary,
    :start_date, :start_datetime, :end_date, :end_datetime,
    :start_time, :end_time, :country, :lang, :allday,
    :twitter_hash, :timezone, :tag_names, :tag_names_str,
    :image, :image_cache, :uris_attributes

  validates :g_id,    :uniqueness => true, :allow_nil => true
  validates :etag,    :presence => true
  validates :summary, :presence => true, :if => :active?
  validates :start_datetime, :presence => true, :if => :active?
  validates :end_datetime,   :presence => true, :if => :active?
  validates :start_date, :presence => true, :if => :active?
  validates :end_date,   :presence => true, :if => :active?
  validates :ical_uid,   :presence => true, :if => :active?
  validates :tz_min, :numericality => {:only_integer => true}, :allow_nil => true
  validates :status, :presence => true, :inclusion => {:in => %w(confirmed cancelled)}
  validates :recur_orig_start_datetime,
    :presence => true, :if => :recurring_instance?
  validates :recur_orig_start_date,
    :presence => true, :if => :recurring_instance?
  validates :start_time, :presence => true, :unless => :allday?
  validates :end_time,   :presence => true, :unless => :allday?

  before_validation :set_dummy_values_for_cancelled,
    :cascade_start_date, :cascade_end_datetime, :cascade_end_date,
    :mangle_tentative_status, :generate_etag, :generate_ical_uid

  after_save :save_tag_order, :save_extra_tags

  after_initialize :init
  def init
    @extra_tags = ExtraTagContainer.new(self)
    @tag_changed = false
  end
  attr_reader :extra_tags

  def name
    summary
  end

  def recurring_instance?
    g_recurring_event_id?
  end

  def cancelled?
    status == "cancelled"
  end
  alias_method :deleted?, :cancelled?

  def active?
    !cancelled?
  end

  def timezone
    self[:timezone].blank? and return nil
    @_timezone ||= ActiveSupport::TimeZone.new(self[:timezone])
  end

  def timezone=(v)
    self[:timezone] = v
    v.blank? and return
    @_timezone = ActiveSupport::TimeZone.new(v)
    self[:tz_min] = @_timezone.utc_offset / 60
  end

  def tz_min=(v)
    raise ArgumentError, "Use Event#timezone= instead."
  end

  def timezone_offset
    Rational.new(timezone.utc_offset/60, 24*60)
  end

  def start_datetime=(v)
    v = convert_to_datetime v
    self[:start_datetime] = v
    self[:start_date] = v.to_date
  end

  def end_datetime=(v)
    v = convert_to_datetime v
    self[:end_datetime] = v
    self[:end_date] = v.to_date
  end

  def start_date=(v)
    v = convert_to_date v
    self[:start_date] = v
    self[:start_datetime] = Time.new(v.year, v.mon, v.day).to_datetime
  end

  def end_date=(v)
    v = convert_to_date v
    self[:end_date] = v
    self[:end_datetime] = Time.new(v.year, v.mon, v.day).to_datetime
  end

  def recur_orig_start_datetime=(v)
    if v.blank?
      self[:recur_orig_start_date] =
        self[:recur_orig_start_datetime] = nil
    else
      v = convert_to_datetime v
      self[:recur_orig_start_datetime] = v
      self[:recur_orig_start_date] = v.to_date
    end
  end

  def recur_orig_start_date=(v)
    if v.blank?
      self[:recur_orig_start_date] =
        self[:recur_orig_start_datetime] = nil
    else
      v = convert_to_date v
      self[:recur_orig_start_date] = v
      self[:recur_orig_start_datetime] = Time.new(v.year, v.mon, v.day).to_datetime
    end
  end

  def start_time
    allday? ? '' : start_datetime.try(:strftime, "%H:%M")
  end

  def end_time
    allday? ? '' : end_datetime.try(:strftime, "%H:%M")
  end

  def start_time=(str)
    str =~ /^(\d{2}):(\d{2})/ or raise ArgumentError.new("Unknonw time format")
    cd = start_datetime.try(:to_datetime) || DateTime.now
    self.start_datetime = DateTime.new(cd.year, cd.mon, cd.day, $1.to_i, $2.to_i, 0, cd.offset)
  end

  def end_time=(str)
    str =~ /^(\d{2}):(\d{2})/ or raise ArgumentError.new("Unknonw time format")
    cd = end_datetime.try(:to_datetime) || DateTime.now
    self.end_datetime = DateTime.new(cd.year, cd.mon, cd.day, $1.to_i, $2.to_i, 0, cd.offset)
  end

  def start_at
    allday? ? start_date : start_datetime
  end

  def end_at
    allday? or return end_datetime
    d = end_date
    DateTime.new(d.year, d.mon, d.day, 0, 0, 0, end_datetime.to_datetime.offset) < end_datetime and
      return (end_datetime + 1.day).to_date
    end_date
  end

  def time_until
    allday? or return end_datetime - 1.second
    end_at - 1.day
  end

  def time_range
    start_at...end_at
  end

  def term_str
    # TODO: Internationalization support!
    s = start_at
    e = allday? ? time_until : end_datetime # Use end_datetime as user friendly display when event is not allday.
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

  def tag_names_str
    tag_names.join(' ')
  end

  def tag_names_str=(v)
    self.tag_names = v.strip.split(VocalendarCore::TagSeparateRegexp)
  end

  def tag_names
    tags.map {|t| t.try(:name) }.compact
  end

  def tag_names=(v)
    @tag_changed = true
    updated_at_will_change!
    self.tags = [v].flatten.compact.map {|t| t.strip }.
      find_all {|t| !t.blank? }.map {|t|
      Tag.find_or_create_by_name(t.gsub(/\s+/, '_'))
    }
  end

  def has_end_time?
    allday? && start_date != (end_date - 1.day) ||
      !allday? && start_datetime != end_datetime
  end

  def g_html_link=(v)
    self[:g_html_link] = v
    if !v.blank? && v =~ /eid=([^;&]+)/
      self[:g_eid] = $1
    else
      self[:g_eid] = nil
    end
  end

  def g_eid=(v)
    self[:g_eid] = v
    if v.blank?
      self[:g_html_link] = nil
    else
      self[:g_html_link] = "https://www.google.com/calendar/event?eid=#{v}"
    end
  end

  # Load attribute has from externel exchange format (e.g. google API)
  def load_exfmt(format, attrs, opts = {})
    respond_to? "load_exfmt_#{format}" or
      raise ArgumentError, "Exchange format #{format} is not supported"
    __send__ "load_exfmt_#{format}", attrs, opts
  end

  def load_exfmt_google_v3(attrs, opts = {})
    opts = {:tag_names_remove => [], :tag_names_append => []}.merge opts
    default_timezone = opts[:default_timezone] || Time.zone.name
    opts[:calendar_id].blank? and
      raise ArgumentError, "Need to specify :calendar_id as option"

    summary = attrs["summary"].to_s.strip
    in_tags = opts[:tag_names_append]
    while summary.sub!(/^【(.*?)】/, '')
      in_tags += $1.split(VocalendarCore::TagSeparateRegexp)
    end
    summary.sub!(/^★/, '') and in_tags << '記念日'
    self.tag_names = (in_tags - opts[:tag_names_remove]).uniq

    assign_attributes({
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
    }, :without_protection => true)
    if attrs["start"]
      assign_attributes({
        start_date: attrs.start["date"] || attrs.start.dateTime.to_date,
        start_datetime: attrs.start["dateTime"] || attrs.start.date.to_time.to_datetime,
        end_date: attrs.end["date"] || attrs.end.dateTime.to_date,
        end_datetime: attrs.end["dateTime"] || attrs.end.date.to_time.to_datetime,
        timezone: attrs.start["timeZone"] || default_timezone,
        allday: !!attrs.start["date"],
        recur_string: attrs.recurrence.to_a.join("\n"),
      }, :without_protection => true)
    end
    if attrs["recurringEventId"]
      orig_sd = attrs["originalStartTime"]
      assign_attributes({
        g_recurring_event_id: attrs.recurringEventId,
        recur_orig_start_date: orig_sd["date"] || orig_sd.dateTime.to_date,
        recur_orig_start_datetime: orig_sd["dateTime"] || orig_sd.date.to_time.to_date,
      }, :without_protection => true)
    else
      assign_attributes({
        g_recurring_event_id: nil,
        recur_orig_start_date: nil,
        recur_orig_start_datetime: nil,
      }, :without_protection => true)

    end
  end

  def to_exfmt(format, opts = {})
    respond_to? "to_exfmt_#{format}" or
      raise ArgumentError, "Exchange format #{format} is not supported"
    __send__ "to_exfmt_#{format}", opts
  end

  def to_exfmt_google_v3(opts = {})
    opts = {:tag_names_remove => [], :tag_names_append => []}.merge opts
    out_tags = tag_names
    has_anniversary = out_tags.delete '記念日'
    tag_str = (opts[:tag_names_append] + out_tags - opts[:tag_names_remove]).uniq.join('/')
    tag_str.blank?  or  tag_str = "【#{tag_str}】"
    has_anniversary and tag_str = "★#{tag_str}"
    summary = tag_str.to_s + summary.to_s
    ret = {
      # :id => g_id, # TODO: If id is set, may get 404 not found.
      :iCalUID => ical_uid,
      :start => 
      if allday? 
        {:date => start_date}
      else
        {:dateTime => start_datetime,
         :timeZone => timezone.try(:name)}
      end,
      :end => 
      if allday?
        {:date => end_date}
      else
        {:dateTime => end_datetime,
         :timeZone => timezone.try(:name)}
      end,
      :summary => summary,
      :description => description,
      :location => location,
      :status => status,
      :recurrence => recur_string.to_s.split("\n"),
      :recurringEventId => g_recurring_event_id,
    }
    if recurring_instance?
      ret[:originalStartTime] =
	if allday?
          {:date => recur_orig_start_date }
        else
          {:dateTime => recur_orig_start_datetime,
           :timeZone => timezone.try(:name) }
        end
    end
    Hashie::Mash.new(ret)
  end

  private
  def cascade_start_date
    self[:start_date] ||= start_datetime.try(:to_date)
    self[:recur_orig_start_date] ||= recur_orig_start_datetime.try(:to_date)
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

  def save_tag_order
    !tags.loaded? && !@tags_changed and return true
    self.tags.each_with_index do |t, i|
      self.main_tag_relations.each do |r|
        r.tag_id == t.id or next
        r.update_attribute :pos, i+1
      end
    end
    @tag_changed = false
    true
  end

  def save_extra_tags
    extra_tags.save
    true
  end

  def convert_to_date(v)
    v.kind_of?(Date) || v.kind_of?(Time) and return v.to_date
    Date.parse(v.to_s)
  end

  def convert_to_datetime(v)
    v.kind_of?(DateTime) and return v
    v.kind_of?(Time)     and return v.to_datetime
    v.kind_of?(Date)     and return Time.new(v.year, v.mon, v.day)
    DateTime.parse("#{v.to_s} #{Time.zone}")
  end

  def generate_etag
    !self[:etag].blank? && !changed? and return
    self[:etag] = SecureRandom.hex(32)
  end

  def generate_ical_uid
    !self[:ical_uid].blank? || !active? and return
    self[:ical_uid] = SecureRandom.hex(24) + "@vocalendar.jp"
  end
end
