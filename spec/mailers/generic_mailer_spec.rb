require "spec_helper"

describe GenericMailer do
  subject { GenericMailer }

  describe "#send_message" do
    it "should send a message" do
      @user = FactoryGirl.create :user
      GenericMailer.send_message(@user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver

      should have_sent_email.
        to(@user.email).
        with_subject("Here is the subject").
        with_part('text/plain', /This is some text\s*/).
        with_part('text/html', %r!<p>This is some HTML</p>!).
        from("play@playhengage.com")
    end

    it "should have an unsubscribe footer" do
      @user = FactoryGirl.create :user
      GenericMailer.send_message(@user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver

      should have_sent_email.
        to(@user.email).
        with_part('text/plain', /Our mailing address is:/).
        with_part('text/html', /Our mailing address is:/)

      # The latter should only show up in the Invitation email.
      # Re-doing check for 'Our mailing address...' so have confidence that the following test works
      should have_sent_email.with_body /Our mailing address is/
      should_not have_sent_email.with_body /Please do not forward it to others/
    end

    it "should be able to interpolate invitation URLs" do
      @user = FactoryGirl.create :user
      GenericMailer.send_message(@user.id, "Here is the subject", "This is some text, and you should go to [invitation_url]", "<p>This is some HTML. Go to [invitation_url]</p>").deliver

      should have_sent_email.
        to(@user.email).
        with_part('text/html', /#{@user.invitation_code}/).
        with_part('text/plain', /#{@user.invitation_code}/)
    end

    context "when called with a user in a demo that has a custom reply address" do
      it "should send from that address" do
        @demo = FactoryGirl.create :demo, :email => "someco@playhengage.com"
        @user = FactoryGirl.create :user, :demo => @demo

        GenericMailer.send_message(@user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver

        should have_sent_email.
          to(@user.email).
          with_subject("Here is the subject").
          with_part('text/plain', /This is some text\s*/).
          with_part('text/html', %r!<p>This is some HTML</p>!).
          from("someco@playhengage.com")
        end
    end
  end

  describe "BulkSender#bulk_generic_messages" do
    it "should send a batch of messages" do
      GenericMailer.stubs(:delay_mail)

      user_ids = []
      5.times {user_ids << (FactoryGirl.create :user).id}
      GenericMailer::BulkSender.new(user_ids, "This is a subject", "This is plain text", "<p>This is HTML</p>").send_bulk_mails
      

      user_ids.each do |user_id|
        GenericMailer.should have_received(:delay_mail).with(:send_message, user_id, "This is a subject", "This is plain text", "<p>This is HTML</p>")
      end

      GenericMailer.should have_received(:delay_mail).times(5)
    end
  end
end
