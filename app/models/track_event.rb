module TrackEvent
  TRACKING_JOB_PRIORITY = 500

  def ping(*args)
    TrackEvent.ping *args
  end

  def ping_page(*args)
    TrackEvent.ping_page *args
  end

  def self.ping(event, data_hash = {}, user = nil)
    data_to_send = user.present? ? data_hash.merge(user.data_for_mixpanel) : data_hash

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay(priority: TRACKING_JOB_PRIORITY).track(event, data_to_send)
  end

  def self.orientation_ping_page(page, data_hash = {}, user = nil)
    ping_page(page, data_hash, user)
  end
    
  def self.orientation_ping(event, property, data_hash = {}, user)
    event = "Orientation - #{event}"
    properties = {action: property}
    self.ping(event, properties.merge(data_hash), user)    
  end
    
  def self.ping_page(page, data_hash = {}, user = nil)
    event = 'viewed page'
    properties = {page_name: page}
    self.ping(event, properties.merge(data_hash), user)
  end
end
