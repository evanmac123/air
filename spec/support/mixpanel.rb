require 'singleton'

class FakeMixpanelTracker
  def self.track(name, properties)
    self.tracked_events << [name, properties]
  end

  def self.clear_tracked_events
    self.tracked_events = []
  end

  def self.events_matching(name, properties = {})
    result = self.tracked_events.select{|event| name === event.first}
    properties.each do |property_key, property_value|
      result = result.select{|event| property_value === event.last[property_key]}
    end

    result
  end

  def self.has_event_matching?(name, properties = {})
    self.events_matching(name, properties).present?
  end

  def self.empty?
    self.tracked_events.empty?
  end

  def self.alias(*args)
  end

  cattr_accessor :tracked_events
end
