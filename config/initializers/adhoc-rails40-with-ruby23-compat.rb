require 'active_support/core_ext/date_time/calculations.rb'

class DateTime
  def <=>(other)
    [nil, true, false].member?(other) and return nil
    super other.to_datetime
  end
end
