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
	json.tags(event.all_tags,
			 :created_at,
			 :hidden,
			 :id,
			 :name
			 )
	
else
pp 'event'
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
pp 'tag'
json.tags(event.all_tags,
		 :created_at,
		 :hidden,
		 :id,
		 :name
		 )
pp 'favorite'
json.favorite_count(event.favorites.count)
pp 'myfavo'
user_signed_in? and 
	json.favorited(event.favorites.where( event_id: event.id, user_id: current_user.id ).exists?)

end 
