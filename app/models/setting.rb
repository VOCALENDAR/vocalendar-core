class Setting < RailsSettings::Base
  default_scope ->{ order('var') }
end
