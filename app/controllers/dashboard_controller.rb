class DashboardController < ApplicationController
  authorize_resource :class => false

  def compare_calendars
    if !params[:a_id].blank? && !params[:b_id].blank? && params[:a_id] != params[:b_id]
      @cal_a = Calendar.find(params[:a_id])
      @cal_b = Calendar.find(params[:b_id])
      @diff = @cal_a.compare_remote_events(@cal_b)
    end
    @calendars = Calendar.all
  end

  def alerts
    @rare_tags = []
    Tag.all.each do |tag|
      tag.events.active.count > 3 and next
      @rare_tags << tag
    end
    @rare_tags.sort_by! {|t| t.events.active.count }

  end
end
