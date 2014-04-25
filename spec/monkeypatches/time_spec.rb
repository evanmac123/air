require "spec_helper"

describe Time do
  let(:time) { Time.zone.parse("2013-12-13 12:17:00") }

  describe "#pretty" do
    it "converts the time into a pretty string" do
      expect(time.pretty).to eq("December 13, 2013 at 12:17 PM Eastern")
    end
  end

  describe "#pretty_succinct" do
    it "converts the time into a pretty, succinct string" do
      expect(time.pretty_succinct).to eq("Dec 13, 2013 @ 12:17 PM")
    end
  end
end
