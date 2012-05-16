require 'spec_helper'

# Dummy mailer with no distinguishing characteristics except that it happens
# to descend from ActionMailer::Base; thus, if this mailer behaves the way we 
# want, there's a good reason to expect that others will too.

class DummyMailer < ActionMailer::Base
  def make_me_a_sandwich(user_id)
    user = User.find(user_id)
    mail(to: [user.email, "snoopy@hengage.com"],
         subject: "Make me a sandwich",
         from: "H Engage <doodz@hengage.com>"
        ) do |format|
          format.text {"Make me a sandwich"}
          format.html {"<p>Make me a sandwich</p>"}
        end
  end
end

describe OutgoingEmail do
  it "should get created with appropriate values whenever an email is sent spontaneously" do
    OutgoingEmail.count.should == 0

    user = Factory :user
    ActionMailer::Base.deliveries.clear

    DummyMailer.delay.make_me_a_sandwich(user.id)
    crank_dj_clear

    outgoing_email = OutgoingEmail.first
    outgoing_email.subject.should == "Make me a sandwich"
    outgoing_email.from.should == "doodz@hengage.com"
    outgoing_email.to.should == "#{user.email},snoopy@hengage.com"
    outgoing_email.raw.should == ActionMailer::Base.deliveries.first.to_s
  end

  it "should get created with appropriate values whenever an email is sent as a reply to an incoming email"
end
