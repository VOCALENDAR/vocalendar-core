class UriValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    begin
      uri = Addressable::URI.parse(value)
      if !["http","https"].include?(uri.scheme)
        raise Addressable::URI::InvalidURIError
      end
    rescue Addressable::URI::InvalidURIError
      object.errors[attribute] << (options[:message] || I18n.t("errors.messages.invalid_uri", default: " is invalid URI"))
    end
  end
end

