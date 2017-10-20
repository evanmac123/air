require 'spec_helper'

describe Integrations::SendgridEventsParser do
  describe "#track_events" do
    it "calls #track_event for each event its passed and returns the events arr" do
      Integrations::SendgridEventsParser.any_instance.expects(:track_event).with(fake_sendgrid_events_arr[0]).once
      Integrations::SendgridEventsParser.any_instance.expects(:track_event).with(fake_sendgrid_events_arr[1]).once

      events = Integrations::SendgridEventsParser.new.track_events(fake_sendgrid_events_arr)

      expect(events).to eq(fake_sendgrid_events_arr)
    end
  end

  describe "#track_event" do
    it "removes email from the event_hash" do
      event = fake_sendgrid_events_arr[0]

      event.expects(:delete).with("email")

      Integrations::SendgridEventsParser.new.track_event(event)
    end

    it "sends a ping with the event name and the event hash" do
      event = fake_sendgrid_events_arr[0]
      event.delete("email")

      TrackEvent.expects(:ping).with("SendGrid: #{event["event"]}", event)

      Integrations::SendgridEventsParser.new.track_event(event)
    end
  end

  def fake_sendgrid_events_arr
    [
      {
        "email"=>"example@test.com",
        "timestamp"=>1508542936,
        "smtp-id"=>"<14c5d75ce93.dfd.64b469@ismtpd-555>",
        "event"=>"processed",
        "category"=>"cat facts",
        "sg_event_id"=>"M0KaRo92wGpS1clK5ox6gg==",
        "sg_message_id"=>"14c5d75ce93.dfd.64b469.filter0001.16648.5515E0B88.0"},
        {"email"=>"example@test.com",
        "timestamp"=>1508542936,
        "smtp-id"=>"<14c5d75ce93.dfd.64b469@ismtpd-555>",
        "event"=>"deferred",
        "category"=>"cat facts",
        "sg_event_id"=>"W5aNQjYjn5JzWnrfQ6tGuw==",
        "sg_message_id"=>"14c5d75ce93.dfd.64b469.filter0001.16648.5515E0B88.0",
        "response"=>"400 try again later",
        "attempt"=>"5"}
      ]
  end
end
