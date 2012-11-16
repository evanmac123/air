class Shotgun
  def self.ping(event, data_hash)
    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track(event, data_hash)
  end

  def self.ping_page(page)
    event = 'viewed page'
    properties = {page_name: page}
    ping(event, properties)
  end
end
