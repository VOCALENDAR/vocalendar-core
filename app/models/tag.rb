class Tag < ActiveRecord::Base
  has_many :tag_relations, :class_name => 'EventTagRelation', :dependent => :delete_all
  has_many :events, :through => :tag_relations
  belongs_to :link, :foreign_key => :primary_link_id, :class_name => 'ExLink'
  has_and_belongs_to_many :calendars

  attr_accessible :name, :link_uri

  validates :name, :presence => true, :format => {:with => /^\S+$/}

  def link?
    !!link
  end

  def link_uri
    link.try :uri
  end

  def link_uri=(v)
    if v.blank?
      self[:primary_link_id] = nil
    else
      l = ExLink.find_or_create_by_uri v
      if l && l.valid?
        self[:primary_link_id] = l.id
      else
        errors[:link_uri] << "is invalid URI"
      end
    end
  end
end
