require 'spec_helper'

describe EmailInfoRequest do
  include Shoulda::Matchers::ActionMailer

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
      Delayed::Worker.new.work_off

      open_email 'team@airbo.com'

      current_email.subject.should include("Demo Request")
      [
        "Dude Duderson",
        "dude@bigco.com",
        "100-500 employees",
        "Big Machines",
        "DEMO REQUEST",
      ].each do |text_piece|
        current_email.body.should include(text_piece)
      end
    end
  end
end
