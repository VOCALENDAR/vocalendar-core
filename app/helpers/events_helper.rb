# -*- coding: utf-8 -*-
module EventsHelper
  def event_gcal_copy_link(event, label = nil, attrs = {}, html_opts = {})
    prefix = event.tag_names.empty? ? "" : "【#{event.tag_names.join('/')}】"
    html_opts = {:target => '_blank', :class => 'btn VC_button'}.merge(html_opts)
    default_attrs = {
      :dates    => 'placeholder', # dummy date to keep order
      :text     => prefix + event.summary,
      :location => event.location.to_s,
      :details  => event.description.to_s,
    }
    if event.allday?
      attrs[:dates] = event.start_datetime.strftime("%Y%m%d") +
        '/' + event.end_datetime.strftime("%Y%m%d")
    else
      # Timezone workaround 
      fmt = "%Y%m%dT%H%M00Z"
      attrs[:dates] = event.start_datetime.to_datetime.new_offset(0).strftime(fmt) +
        '/' + event.end_datetime.to_datetime.new_offset(0).strftime(fmt)
    end
    attrs = default_attrs.merge(attrs)
    urlbase = 'https://www.google.com/calendar/event?action=TEMPLATE&'
    url = urlbase + attrs.map{|k, v| "#{k}=#{CGI.escape(v)}"}.join('&')
    link_to label || t("general.copy_to_google_calendar"), url, html_opts
  end

  def event_gcal_original_link(event, label = nil, html_opts = {})
    event.g_html_link or return
    label ||= t "general.show_in_google_calendar"
    link_to label, event.g_html_link, html_opts
  end
end
