module TrackEvent
  TRACKING_JOB_PRIORITY = 500

  def ping(*args)
    TrackEvent.ping *args
  end

  def ping_page(*args)
    TrackEvent.ping_page *args
  end

  def ping_action_after_dash(description, args, user=nil)
    parts = description.split(/\s+-\s+/)
    (event, action) = parts
    _args = args.merge(action: action)
    ping(event, _args, user)
  end

  def self.ping(event, data_hash = {}, user = nil)
    data_to_send = user.present? ? data_hash.merge(user.data_for_mixpanel) : data_hash
    

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay(priority: TRACKING_JOB_PRIORITY).track(event, data_to_send)
  end

  def self.ping_page(page, data_hash = {}, user = nil)
    event = 'viewed page'
    properties = {page_name: page}
    self.ping(event, properties.merge(data_hash), user)
  end

  def self.ping_action(event, action, user, properties = {})
    properties ||= {}
    properties[:action] = action
    self.ping(event, properties.merge(user.data_for_mixpanel), user)
  end
end
