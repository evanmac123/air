require "spec_helper"

describe GenericMailer do
  subject { GenericMailer }

  describe "#generic_message" do
    it "should send a message" do
      @user = FactoryGirl.create :user
      GenericMailer.send_message(@user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver

      should have_sent_email.
        to(@user.email).
        with_subject("Here is the subject").
        with_part('text/plain', 'This is some text').
        with_part('text/html', '<p>This is some HTML</p>').
        from("play@playhengage.com")
    end

    context "when called with a user in a demo that has a custom reply address" do
      it "should send from that address" do
        @demo = FactoryGirl.create :demo, :email => "someco@playhengage.com"
        @user = FactoryGirl.create :user, :demo => @demo

        GenericMailer.send_message(@user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver

        should have_sent_email.
          to(@user.email).
          with_subject("Here is the subject").
          with_part('text/plain', 'This is some text').
          with_part('text/html', '<p>This is some HTML</p>').
          from("someco@playhengage.com")
        end
    end
  end

  describe "BulkSender#bulk_generic_messages" do
    it "should send a batch of messages" do
      deliver_stub = stub(:deliver => true)
      GenericMailer.stubs(:send_message).returns(deliver_stub)

      user_ids = []
      5.times {user_ids << (FactoryGirl.create :user).id}
      GenericMailer::BulkSender.bulk_generic_messages(user_ids, "This is a subject", "This is plain text", "<p>This is HTML</p>")

      Delayed::Worker.new.work_off(10)

      user_ids.each do |user_id|
        GenericMailer.should have_received(:send_message).with(user_id, "This is a subject", "This is plain text", "<p>This is HTML</p>")
      end

      deliver_stub.should have_received(:deliver).times(5)
    end
  end
end
