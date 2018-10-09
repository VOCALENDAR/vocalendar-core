class Tag < ActiveRecord::Base
  has_many :tag_relations, :class_name => 'EventTagRelation', :dependent => :delete_all
  has_many :events, :through => :tag_relations
  has_and_belongs_to_many :calendars
  belongs_to :link, :foreign_key => :primary_link_id,
    :class_name => 'ExLink', :autosave => true

  # rails 4 chenge strong_parameters
  #attr_accessible :name, :link_uri, :hidden

  validates :name, :presence => true, :uniqueness => true,
    :format => {:with => /\A\S+\Z/}

  after_validation :copy_link_errors

  class << self
    def cleanup_unused_tags(gap = nil)
      gap ||= 30.minutes
      deleted = []
      where("created_at <= ?", DateTime.now - gap).each do |tag|
        tag.events.count(:id) > 0 and next
        Rails.logger.info "Removing unused tag #{tag.name}"
        tag.destroy
        deleted << tag
      end
      deleted
    end
  end

  def link?
    !!link
  end
  alias_method :uri?,      :link?
  alias_method :link_uri?, :link?

  def link_uri
    link.try :uri
  end
  alias_method :uri, :link_uri

  def link_uri=(v)
    if v.blank?
      self.link = nil
    else
      self.link = ExLink.find_or_create_by_uri v
    end
  end
  alias_method :uri=, :link_uri=

  private
  def copy_link_errors
    errors.has_key? :"primary_link.uri" or return
    errors[:uri] = errors[:primary_link_uri] = errors[:"primary_link.uri"]
  end
end
