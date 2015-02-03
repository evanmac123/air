module MixpanelHelper
  def mp_track(event, properties={})
    properties ||= {} # in some cases nil gets passed in semi-explicitly
    _properties = properties.merge(device_type: device_type)
    javascript_tag do
      raw <<-END_JS
        mixpanel.track('#{event}', #{_properties.to_json});
        window.setTimeout(function() { mixpanel.register({first_time_user: false}); }, 500);
      END_JS
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
