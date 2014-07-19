#Google Analytics設定
if !ENV["http_proxy"].blank?
  proxy_host = URI.parse(ENV["http_proxy"]).host
  proxy_port = URI.parse(ENV["http_proxy"]).port
end

ga = YAML.load_file "#{Rails.root}/config/google-analytics.yml"

config = {
    uri: URI.parse("http://www.google-analytics.com/collect"),
    proxy_host: proxy_host,
    proxy_port: proxy_port,
    tracking_id: ga[Rails.env]["tracking_id"],
    type: "pageview",
    cid: "7f52487e-1598-41d5-8aee-33e42e65e6c0"

  }
Rails.configuration.ga_config = config

