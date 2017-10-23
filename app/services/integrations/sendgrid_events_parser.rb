class Integrations::SendgridEventsParser
  def track_events(events)
    events.each { |e|
      track_event(e)
    }
  end

  def track_event(e)
    e.delete("email")
    TrackEvent.ping("SendGrid: #{e["event"]}", e)
  end
end
