if params['minInfo'] 

	json.(event,
		:allday,
		:end_date,
		:end_datetime,
		:g_eid,
		:g_html_link,
		:g_id,
		:ical_uid,
		:id,
		:start_date,
		:start_datetime,
		:status,
		:summary
		)
	json.tags(event.tags,
			 :created_at,
			 :hidden,
			 :id,
			 :name
			 )
	
else
json.(event,
		:allday,
		:country,
		:created_at,
		:description,
		:end_date,
		:end_datetime,
		:g_calendar_id,
		:g_creator_email,
		:g_eid,
		:g_html_link,
		:g_id,
		:g_recurring_event_id,
		:ical_uid,
		:id,
		:lang,
		:location,
		:primary_link_id,
		:recur_orig_start_date,
		:recur_orig_start_datetime,
		:recur_string,
		:start_date,
		:start_datetime,
		:status,
		:summary,
		:tz_min,
		:updated_at
		)
json.timezone(event.timezone,
		:name,
		:utc_offset
		)
json.related_links(event.related_links,
		:created_at,
		:title,
		:id,
		:uri
		)
json.tags(event.tags,
		 :created_at,
		 :hidden,
		 :id,
		 :name
		 )
json.favorite_count(event.favorites.size)
if user_signed_in?
	fav = false
	event.favorites.each do |favorite|
		if favorite.user_id == current_user.id
			fav = true
		end
	end
	json.favorited(fav)
end

end 
