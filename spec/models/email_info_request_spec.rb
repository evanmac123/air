require 'spec_helper'

describe EmailInfoRequest do
  include Shoulda::Matchers::ActionMailer

  describe "#notify" do
    it "should create a job that notifies sales" do
      ActionMailer::Base.deliveries.clear

      request = EmailInfoRequest.create!(
        name:    'Dude Duderson',
        email:   'dude@bigco.com',
        comment: 'Hot shit!',
        company: "Big Machines",
        source: "demo_request"
      )

      request.notify
      Delayed::Worker.new.work_off

      open_email 'team@airbo.com'

      current_email.subject.should include("Demo Request")
      [
        "Dude Duderson",
        "dude@bigco.com",
        "Hot shit!",
        "Big Machines",
      ].each do |text_piece|
        current_email.body.should include(text_piece)
      end
    end
  end

  describe "#notify" do
    it "should create a job that notifies sales" do
      ActionMailer::Base.deliveries.clear

      request = EmailInfoRequest.create!(
        name:    'Dude Duderson',
        email:   'dude@bigco.com',
        comment: 'Hot shit!',
        company: "Big Machines",
        source: "signup"
      )

      request.notify
      Delayed::Worker.new.work_off

      open_email 'team@airbo.com'

      current_email.subject.should include("Signup Request")
    end
  end
end
