require 'spec_helper'

describe EmailInfoRequest do
  include Shoulda::Matchers::ActionMailer 

  describe "#notify_the_ks_of_demo_request" do
    it "should create a job that notifies Vlad that someone wants our wares" do
      ActionMailer::Base.deliveries.clear

      request = EmailInfoRequest.create!(:name => 'Dude Duderson', :email => 'dude@bigco.com', :comment => 'Hot shit!')
      request.notify_the_ks_of_demo_request
      Delayed::Worker.new.work_off

      should have_sent_email.to('team_k@hengage.com').with_body(/Dude Duderson.*dude@bigco.com.*Comment.*Hot shit!/m).with_subject(/Information Request/)
    end
  end
end
