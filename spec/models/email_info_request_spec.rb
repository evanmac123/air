require 'spec_helper'

describe EmailInfoRequest do
  include Shoulda::Matchers::ActionMailer

  describe "#notify_sales_of_demo_request" do
    it "should create a job that notifies sales" do
      ActionMailer::Base.deliveries.clear

      request = EmailInfoRequest.create!(
        name:    'Dude Duderson',
        email:   'dude@bigco.com',
        comment: 'Hot shit!',
        company: "Big Machines",
      )

      request.notify_sales_of_demo_request
      Delayed::Worker.new.work_off

      open_email 'team_k@airbo.com'

      current_email.subject.should include("Information Request")
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

  describe "#notify_sales_of_signup_request" do
    it "should create a job that notifies sales" do
      ActionMailer::Base.deliveries.clear

      request = EmailInfoRequest.create!(
        name:    'Dude Duderson',
        email:   'dude@bigco.com',
        comment: 'Hot shit!',
        company: "Big Machines",
      )

      request.notify_sales_of_signup_request
      Delayed::Worker.new.work_off

      open_email 'team_k@airbo.com'

      current_email.subject.should include("Signup Request")
    end
  end
end
