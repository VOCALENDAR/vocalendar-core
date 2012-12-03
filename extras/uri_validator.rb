class UriValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    err_class = Addressable::URI::InvalidURIError
    begin
      #value =~ %r{^https?://} or raise err_class
      uri = Addressable::URI.parse(value)
      ["http","https"].include?(uri.scheme) or raise err_class
      uri.host.to_s.include?(".") or raise err_class
    rescue err_class
      object.errors[attribute] << (options[:message] || I18n.t("errors.messages.invalid_uri", default: " is invalid URI"))
    end
  end
end

