module ExLinksHelper
  def format_ex_link(link, opts = {})
    link.blank? and return ""

    default_opts = {
      :max_length => 60,
      :short_url => true,
      :type_icon => true,
      :label => nil,
    }
    html_opts = opts.dup
    default_opts.keys.each { |k| html_opts.delete k }
    opts = default_opts.merge opts

    ret = "".html_safe

    label = opts[:label] || (link.title? ? link.title : link.uri)
    opts[:max_length] and
      label = truncate(label, :length => opts[:max_length])

    link.disabled? and
      return content_tag :span, content_tag(:del, label), {:class => 'ex-link'}.merge(html_opts)

    uri = opts[:short_url] ? link_redirect_path(link.short_id) : link.uri
    ret += link_to label, uri, :title => link.uri

    opts[:type_icon] and
      ret += image_tag("site-icons/#{link.typename}.png",
                       :class => "ex-link-icon", :height => 16, :width => 16,
                       :alt => t("ex_links.types.#{link.typename}",
                                 :default => link.typename.camelcase))

    content_tag :span, ret, {:class => 'ex-link'}.merge(html_opts)
  end

  def auto_link(text)
    ExLink.gsub(h(text)) {|link, uri_text|
      format_ex_link link, :label => uri_text, :type_icon => false, :max_length => 80
    }.html_safe
  end
end
