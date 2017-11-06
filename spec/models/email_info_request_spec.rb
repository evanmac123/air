require 'spec_helper'

describe EmailInfoRequest do
  describe "#notify" do
    it "should create a job that notifies sales" do
      ActionMailer::Base.deliveries.clear

      request = EmailInfoRequest.create!(
        name:    'Dude Duderson',
        email:   'dude@bigco.com',
        company: "Big Machines",
        size: "100-500 employees",
        source: "demo_request"
      )

      request.notify

      open_email 'team@airbo.com'

      expect(current_email.subject).to include("Demo Request")
      [
        "Dude Duderson",
        "dude@bigco.com",
        "100-500 employees",
        "Big Machines",
        "DEMO REQUEST",
      ].each do |text_piece|
        expect(current_email.body).to include(text_piece)
      end
    end
  end
end
