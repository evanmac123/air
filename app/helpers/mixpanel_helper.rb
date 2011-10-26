module MixpanelHelper
  def mp_track(event, properties={})
    javascript_tag do
      raw "mpq.track('#{event}', #{properties.to_json})"
    end
  end
end
