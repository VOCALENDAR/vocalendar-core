# coding: utf-8
module ExternalUi::ReleaseEventsHelper

  def media_to_class( media_str )
    
    clazz = media_str.downcase
    
    if clazz == "ニコ動" then
      clazz = 'niconico'
    end
    
    return clazz
  end

end
