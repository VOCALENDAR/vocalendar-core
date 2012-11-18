class Setting < RailsSettings::CachedSettings
  default_scope order('var')
end
