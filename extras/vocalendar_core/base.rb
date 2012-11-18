module VocalendarCore
  class GoogleAPIError < StandardError
    def initialize(result, msg)
      @api_result = result
      super(msg)
    end
    attr_accessor :api_result
  end

  class CalendarSyncError < StandardError; end
end
