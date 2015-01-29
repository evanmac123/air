require 'spec_helper'

describe EmailInfoRequest do
  include Shoulda::Matchers::ActionMailer 

  describe "#notify_the_ks_of_demo_request" do
    it "should create a job that notifies us that someone wants our wares" do
      ActionMailer::Base.deliveries.clear

      request = EmailInfoRequest.create!(
        name:    'Dude Duderson', 
        email:   'dude@bigco.com', 
        comment: 'Hot shit!', 
        company: "Big Machines", 
        role:    "Widget Flinger", 
      )

      request.notify_the_ks_of_demo_request
      Delayed::Worker.new.work_off

      open_email 'team_k@airbo.com'
      current_email.subject.should include("Information Request")
      [
        "Dude Duderson",
        "dude@bigco.com",
        "Hot shit!",
        "Big Machines",
        "Widget Flinger",
      ].each do |text_piece|
        current_email.body.should include(text_piece)
      end
    end
  end
end
