module MixpanelHelper
  def mp_track(event, properties={})
    javascript_tag do
      raw "mixpanel.track('#{event}', #{properties.to_json})"
    end
  end

  def mp_track_page(page_name, properties = {})
    _properties = {:page_name => page_name}

    if current_user
      _properties = _properties.merge(current_user.data_for_mixpanel)
    end

    _properties = _properties.merge(properties)
    mp_track("viewed page", _properties)
  end
end
