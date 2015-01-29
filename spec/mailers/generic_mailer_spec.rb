require "spec_helper"

describe GenericMailer do
  subject { GenericMailer }
  let (:demo) {FactoryGirl.create :demo}

  # The 1's leading send_message are a dummy demo ID.

  describe "#send_message" do
    it "should send a message" do
      @user = FactoryGirl.create :user
      GenericMailer.send_message(demo.id, @user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver

      should have_sent_email.
        to(@user.email).
        with_subject("Here is the subject").
        with_part('text/plain', /This is some text\s*/).
        with_part('text/html', %r!<p>This is some HTML</p>!).
        from("play@ourairbo.com")
    end

    it "should have an unsubscribe footer" do
      @user = FactoryGirl.create :user
      GenericMailer.send_message(demo.id, @user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver

      should have_sent_email.to(@user.email)      
      should_not have_sent_email.with_body /Please do not forward it to others/
    end

    it "should not try to send to an empty email address" do
      users = FactoryGirl.create_list(:user, 2)
      users.first.update_attributes(email: nil)
      users.last.update_attributes(email: '')

      users.each do |user|
        GenericMailer.send_message(demo.id, user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver
      end

      ActionMailer::Base.deliveries.should be_empty
    end

    it "should be able to interpolate invitation URLs" do
      @user = FactoryGirl.create :user
      GenericMailer.send_message(demo.id, @user.id, "Here is the subject", "This is some text, and you should go to [invitation_url]", "<p>This is some HTML. Go to [invitation_url]</p>").deliver

      should have_sent_email.
        to(@user.email).
        with_part('text/html', /#{@user.invitation_code}/).
        with_part('text/plain', /#{@user.invitation_code}/)
    end

    it "should be able to interpolate tile-digest style URLs" do
      claimed_user = FactoryGirl.create :user, :claimed
      unclaimed_user = FactoryGirl.create :user

      [claimed_user, unclaimed_user].each do |user|
        GenericMailer.send_message(demo.id, user.id, "Das Subjekt", "This is some text, go to [tile_digest_url]", "<p>This is some HTML, go to [tile_digest_url]").deliver
      end

      should have_sent_email.
        to(claimed_user.email).
        with_part('text/html', /acts/).
        with_part('text/html', /user_id=#{claimed_user.id}/).
        with_part('text/html', /tile_token=#{EmailLink.generate_token(claimed_user)}/).
        with_part('text/plain', /acts/).
        with_part('text/plain', /user_id=#{claimed_user.id}/).
        with_part('text/plain', /tile_token=#{EmailLink.generate_token(claimed_user)}/)
 
      should have_sent_email.
        to(unclaimed_user.email).
        with_part('text/html', %r!invitations/#{unclaimed_user.invitation_code}!).
        with_part('text/plain', %r!invitations/#{unclaimed_user.invitation_code}!)
    end

    context "when called with a user in a demo that has a custom reply address" do
      it "should send from that address" do
        @demo = FactoryGirl.create :demo, :email => "someco@playhengage.com"
        @user = FactoryGirl.create :user, :demo => @demo

        GenericMailer.send_message(@demo.id, @user.id, "Here is the subject", "This is some text", "<p>This is some HTML</p>").deliver

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
      GenericMailer::BulkSender.new(demo.id, user_ids, "This is a subject", "This is plain text", "<p>This is HTML</p>").send_bulk_mails
      

      user_ids.each do |user_id|
        GenericMailer.should have_received(:delay_mail).with(:send_message, demo.id, user_id, "This is a subject", "This is plain text", "<p>This is HTML</p>")
      end

      GenericMailer.should have_received(:delay_mail).times(5)
    end
  end
end
