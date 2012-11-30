module ApplicationHelper
  def bs_icon(name, opts = {})
    opts[:class] ||= ""
    opts[:class].prepend "icon-#{name} "
    content_tag :i, ''.html_safe, opts
  end
end
