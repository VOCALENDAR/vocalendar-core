# -*- coding: utf-8 -*-
module VocalendarCore

  TagSeparateRegexp = %r{(?:\s|[/／])+}

  class CalendarSyncError < StandardError; end
  class GoogleAPIError < StandardError; end

  class GoogleAPIRequestError < GoogleAPIError
    def initialize(result)
      @api_result = result
      apierr = result.response.body
      begin
        apierr = JSON.parse apierr
        apierr = apierr["error"]["message"]
      rescue
        # ignore
      end
      super("Error on Google API request #{result.request.api_method.id}: #{apierr} (#{result.status})")
    end
    attr_accessor :api_result
  end

end
