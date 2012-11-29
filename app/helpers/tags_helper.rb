module TagsHelper
  def format_tag(tag, opts = {})
    ret = "".html_safe
    tag.hidden? && (!user_signed_in? || !current_user.editor?) and return ret

    default_opts = {
      :url         => nil,
      :edit_icon   => true,
      :hidden_icon => true,
      :link_icon   => true,
      :label       => nil
    }
    opts = default_opts.merge(opts)
    html_opts = opts.dup
    default_opts.keys.each {|k| html_opts.delete k }

    label = opts[:label] || "#{h(tag.name)}(#{tag.events.active.count(:id)})".html_safe
    link_url = opts[:link_url] || tag_events_path(tag)
    ret << link_to(label, link_url)

    opts[:hidden_icon] && tag.hidden? and
      ret << '<i class="icon-eye-close tag-link-icon"></i>'.html_safe

    opts[:show_icon] and
      ret << link_to('<i class="icon-search tag-link-icon"></i>'.html_safe,
                     tag, :class => 'tag-link-edit')

    opts[:edit_icon] && can?(:edit, tag) and
      ret << link_to('<i class="icon-pencil tag-link-icon"></i>'.html_safe,
                     edit_tag_path(tag), :class => 'tag-link-edit')

    opts[:link_icon] && tag.link? and
      ret << format_ex_link(tag.link, :type_icon => false,
                            :label => '<i class="icon-globe tag-link-icon"></i>'.html_safe)
    
    content_tag :span, ret, {:class => 'tag-link'}.merge(html_opts)
  end
end
