class Calendar < ActiveRecord::Base
  default_scope order('io_type desc, name')

  attr_accessible :name, :external_id, :synced_at, :io_type

  validates :name, :presence => true
  validates :external_id, :presence => true, :uniqueness => true
  validates :io_type, :presence => true, :inclusion => {:in => %w(src dst)}

  before_validation :trim_attrs

  private
  def trim_attrs
    self[:name].strip!
    self[:external_id].strip!
    self[:io_type].strip!
  end
end
