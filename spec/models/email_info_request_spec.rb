require 'spec_helper'

describe EmailInfoRequest do
  include Shoulda::Matchers::ActionMailer 

  describe "after create" do
    before(:each) do
      EmailInfoRequest.create!(:name => 'Dude Duderson', :email => 'dude@bigco.com')
    end

    context "should create a job that notifies Vlad that someone wants our wares" do
      before(:each) do
        ActionMailer::Base.deliveries.should be_empty

        Delayed::Worker.new.work_off
      end

      it { should have_sent_email.to('vlad@hengage.com').with_body(/Dude Duderson \(dude@bigco.com\)/).with_subject(/Somebody requested information about The H Engages!/) }
    end
  end
end
