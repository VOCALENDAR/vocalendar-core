class ExLinkAccess < ActiveRecord::Base
  default_scope -> { order('created_at desc') }
  belongs_to :ex_link
end
