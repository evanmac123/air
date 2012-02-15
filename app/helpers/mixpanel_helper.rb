module MixpanelHelper
  def mp_track(event, properties={})
    #javascript_tag do
      #raw "mpq.track('#{event}', #{properties.to_json})"
    #end
  end

  def mp_track_page(page_name, properties = {})
    mp_track("viewed #{page_name} page", properties)
  end
end
