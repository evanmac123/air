require 'spec_helper'

describe Api::SendgridEventsController do
  describe "POST create" do
    it "asks SendgridEventsParser to #track_events and return the events" do
      fake_sendgrid_events_hash = { "_json" => "EVENTS" }

      Integrations::SendgridEventsParser.any_instance.expects(:track_events).with(fake_sendgrid_events_hash["_json"]).returns(fake_sendgrid_events_hash["_json"])

      post(:create, fake_sendgrid_events_hash)

      expect(response.status).to eq(200)
      expect(response.content_type.json?).to eq(true)
      expect(response.body).to eq(fake_sendgrid_events_hash["_json"].to_json)
    end
  end
end
