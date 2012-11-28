# -*- ruby, conding: utf-8 -*-
desc "Update mainsite dummy layout (views/layout/mainsite_dummy.html.erb)"
task :update_mainsite_dummy_layout do
  require 'open-uri'
  html = nil
  open("http://vocalendar.jp/") do |f|
    html = f.read
  end
  html.blank? and raise "Can't get HTML from remote site."
  open "#{Rails.root}/app/views/layouts/mainsite_dummy.html.erb", "w" do |f|
    html.gsub!(%r{((href|src)=['"](?!https?://))/?}, '\1http://vocalendar.jp/')  # '
    html.sub!(%r{</header>.*?<footer>}m, "</header>\n<%= yield %>\n<footer>") # "
    html.sub!(%r{var _gaq.*?</script}m, '</script') #'
    f << html
  end
end
