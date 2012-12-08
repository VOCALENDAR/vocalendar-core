module ExLinksHelper
  def format_ex_link(link, opts = {})
    default_opts = {
      :max_length => 60,
      :short_url => true,
      :type_icon => true,
      :label => nil,
      :title => nil,
    }
    html_opts = opts.dup
    default_opts.keys.each { |k| html_opts.delete k }
    opts = default_opts.merge opts

    if link.blank?
      if opts[:label].blank?
        return "".html_safe
      else
        return truncate(opts[:label], :length => opts[:max_length])
      end
    end

    ret = "".html_safe

    label = opts[:label] || (link.title? ? link.title : link.uri)

    safe_flag = label.html_safe?
    opts[:max_length] and
      label = truncate(label, :length => opts[:max_length])
    safe_flag and label = label.html_safe

    link.disabled? and
      return content_tag :span, content_tag(:del, label), {:class => 'ex-link'}.merge(html_opts)

    uri = opts[:short_url] ? link_redirect_path(link.short_id) : link.uri
    ret += link_to label, uri, :title => (opts[:title] || link.uri)

    opts[:type_icon] and
      ret += image_tag("site-icons/#{link.typename}.png",
                       :class => "ex-link-icon", :height => 16, :width => 16,
                       :alt => t("ex_links.types.#{link.typename}",
                                 :default => link.typename.camelcase))

    content_tag :span, ret, {:class => 'ex-link'}.merge(html_opts)
  end

  def auto_link(text, opts = {})
    opts = {:type_icon => false, :max_length => 80}.merge(opts)
    ExLink.gsub(h(text)) {|link, uri_text|
      format_ex_link link, opts.merge(:label => uri_text, :title => link.title)
    }.html_safe
  end
end
