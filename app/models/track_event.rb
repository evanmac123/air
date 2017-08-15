module TrackEvent
  TRACKING_JOB_PRIORITY = 500

  def ping(*args)
    TrackEvent.ping(*args)
  end

  def self.ping(event, data_hash = {}, user = nil)
    data_to_send = user.present? ? data_hash.merge(user.data_for_mixpanel) : data_hash

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay(priority: TRACKING_JOB_PRIORITY).track(event, data_to_send)
  end
end
