module ApplicationHelper
  def bs_icon(name, opts = {})
    opts[:class] ||= ""
    opts[:class] += " icon-#{name}"
    content_tag :i, ''.html_safe, opts
  end

  def graph_count_by_date(data, keyfield, range = nil)
    render :partial => 'misc/graph_count_by_date',
      :locals => {:data => data, :field => keyfield, :range => range}
  end
end
