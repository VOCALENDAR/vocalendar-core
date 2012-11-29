module ExLinksHelper
  def exlink(link, opts = {})
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
      label = label.sub(/^(.{#{opts[:max_length]}}).*/m, '\1...')
    uri = opts[:short_url] ? link_redirect_path(link.short_id) : link.uri
    ret += link_to label, uri, :title => link.uri
    opts[:type_icon] and
      ret += image_tag("site-icons/#{link.typename}.png",
                       :class => "ex-link-icon", :height => 16, :width => 16,
                       :alt => t("ex_links.types.#{link.typename}",
                                 :default => link.typename.camelcase))
    content_tag :span, ret, {:class => 'ex-link'}.merge(html_opts)
  end
end
