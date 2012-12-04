class ReleaseEvent < Event
  before_save :copy_link_to_location

  %w(producer media vocaloid_char movie_author illust_author).each do |f|
    define_method(f.pluralize) {
      extra_tags[f].names
    }

    define_method("#{f.pluralize}_str") {
      extra_tags[f].names_str
    }

    define_method("#{f}_tags") {
      extra_tags[f]
    }

    define_method("#{f.pluralize}=") { |v|
      extra_tags[f].names = v
    }
    attr_accessible f.pluralize

    define_method("#{f.pluralize}_str=") { |v|
      extra_tags[f].names_str = v
    }
    attr_accessible "#{f.pluralize}_str"

    define_method("#{f}_tags=") { |v|
      extra_tags[f] = v
    }
    attr_accessible "#{f.pluralize}_tags"
  end

  private
  def copy_link_to_location
    self[:location] = primary_link_uri
  end
end
