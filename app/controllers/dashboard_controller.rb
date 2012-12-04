# -*- coding: utf-8 -*-
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
      tag.events.active.count(:id) > 3 and next
      @rare_tags << tag
    end
    @rare_tags.sort_by! {|t| t.events.active.count(:id) }

    @weird_events = {
      :title_too_long_or_short =>
      Event.active.where("length(summary) > 100 or length(summary) < 3").to_a,
      :title_has_tag_paren =>
      Event.active.where("summary like '%【%'").to_a,
      :title_is_empty =>
      Event.active.where(:summary => "").to_a,
      :title_has_over_3_white_spaces =>
      Event.active.where("summary like '%   %' or summary like '%　　　%'").to_a,
    }
    @weird_events.each do |k, e|
      e.empty? or next
      @weird_events.delete k
    end

  end
end
