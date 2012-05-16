require 'spec_helper'

describe OutgoingEmail do
  it "should get created with appropriate values whenever an email is sent" do
    OutgoingEmail.count.should == 0

    user = FactoryGirl.create :user
    ActionMailer::Base.deliveries.clear

    DummyMailer.delay.make_me_a_sandwich(user.id)
    crank_dj_clear

    outgoing_email = OutgoingEmail.first
    outgoing_email.subject.should == "Make me a sandwich"
    outgoing_email.from.should == "doodz@hengage.com"
    outgoing_email.to.should == "#{user.email},snoopy@hengage.com"
    outgoing_email.raw.should == ActionMailer::Base.deliveries.first.to_s
  end
end
