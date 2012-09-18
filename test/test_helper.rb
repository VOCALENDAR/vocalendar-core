ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...


  def hash_to_struct(h)
    h.each do |k, v|
      Hash === v or next
      h[k] = hash_to_struct(v)
    end
    s = OpenStruct.new(h)
    def s.[](k)
      self.__send__ k
    end
    s
  end
end
