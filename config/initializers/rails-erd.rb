if Rails.env.development?
  RailsERD.options.instance_eval { |o|
    o.title = "Vocalendar Core model diagram"
    o.filetype = 'png'
    o.indirect = true
    o.inheritance = true
    o.polymorphism = true
    o.attributes = %w(foreign_keys timestamps inheritance content)
    o.exclude = %w(RailsSettings::Settings RailsSettings::ScopedSettings RailsSettings::CachedSettings).map {|c| c.to_sym }
  }
end
  
