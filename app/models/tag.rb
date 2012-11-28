class Tag < ActiveRecord::Base
  has_many :tag_relations, :class_name => 'EventTagRelation', :dependent => :delete_all
  has_many :events, :through => :tag_relations
  belongs_to :link, :foreign_key => :primary_link_id, :class_name => 'ExLink'
  has_and_belongs_to_many :calendars

  attr_accessible :name, :link_attributes
  accepts_nested_attributes_for :link,
    :reject_if => lambda { |a| a[:uri].blank? }

  validates :name, :presence => true, :format => {:with => /^\S+$/}

  def link?
    !!link
  end

  def link_uri
    link.try :uri
  end
  alias_method :uri, :link_uri

  def link_uri=(v)
    l = link || build_link
    l.update_attribute :uri, v
  end
  alias_method :uri=, :link_uri=

  def link_name
    link.try :name
  end

  def link_name=(v)
    link or raise "Create link or call link_uri= before set link name."
    link.update_attribute :name, v
  end

end
