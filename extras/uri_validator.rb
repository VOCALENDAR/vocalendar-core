class UriValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    begin
      uri = Addressable::URI.parse(value)
      if !["http","https"].include?(uri.scheme)
        raise Addressable::URI::InvalidURIError
      end
    rescue Addressable::URI::InvalidURIError
      object.errors[attribute] << (options[:message] || "is invalid URL")
    end
  end
end

