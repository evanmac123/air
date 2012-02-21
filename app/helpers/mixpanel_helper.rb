module MixpanelHelper
  def mp_track(event, properties={})
    javascript_tag do
      raw "mpq.track('#{event}', #{properties.to_json})"
    end
  end

  def mp_track_page(page_name, properties = {})
    _properties = {:page_name => page_name}.merge(properties)
    mp_track("viewed page", _properties)
  end
end
