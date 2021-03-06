require "spec_helper"

describe GenericMailer do
  subject { GenericMailer }
  let (:demo) {FactoryBot.create :demo}

  # The 1's leading send_message are a dummy demo ID.

  describe "#send_message" do
    it "should send a message" do
      @user = FactoryBot.create :user
      mail = GenericMailer.send_message(demo.id, @user.id, "Here is the subject", "<p>This is some HTML</p>").deliver_now

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(mail.subject).to eq("Here is the subject")
      expect(mail.to).to eq([@user.email])
      expect(mail.from).to eq(["play@ourairbo.com"])

      expect(mail.body).to include("<p>This is some HTML</p>")
    end

    it "should have an unsubscribe footer" do
      @user = FactoryBot.create :user
      mail = GenericMailer.send_message(demo.id, @user.id, "Here is the subject", "<p>This is some HTML</p>")

      expect(mail.to).to eq([@user.email])
      expect(mail.body).to_not include("Please do not forward it to others")
    end

    it "should be able to interpolate invitation URLs" do
      @user = FactoryBot.create :user
      mail = GenericMailer.send_message(demo.id, @user.id, "Here is the subject", "<p>This is some HTML. Go to [invitation_url]</p>")

      expect(mail.body).to include("#{@user.invitation_code}")
    end

    context "when user is claimed" do
      it "should be able to interpolate tile-digest style URLs" do
        claimed_user = FactoryBot.create :user, :claimed

        mail = GenericMailer.send_message(demo.id, claimed_user.id, "Das Subjekt", "<p>This is some HTML, go to [tile_digest_url]")

        expect(mail.body).to include("tile_token=#{EmailLink.generate_token(claimed_user)}")
      end
    end

    context "when user is unclaimed" do
      it "should be able to interpolate tile-digest style URLs" do
        unclaimed_user = FactoryBot.create :user

        mail = GenericMailer.send_message(demo.id, unclaimed_user.id, "Das Subjekt", "<p>This is some HTML, go to [tile_digest_url]")

        expect(mail.body).to include("invitations/#{unclaimed_user.invitation_code}")
      end
    end

    context "when called with a demo that has custom reply address" do
      it "should send from that address" do
        @demo = FactoryBot.create :demo, :email => "someco@playhengage.com"
        @user = FactoryBot.create :user, :demo => @demo

        mail = GenericMailer.send_message(@demo.id, @user.id, "Here is the subject", "<p>This is some HTML</p>")

        expect(mail.from).to eq(["someco@playhengage.com"])
      end
    end
  end

  describe "BulkSender#bulk_generic_messages" do
    it "should send a batch of messages" do

      user_ids = []
      5.times {user_ids << (FactoryBot.create :user).id}
      GenericMailer::BulkSender.new(demo.id, user_ids, "This is a subject", "<p>This is HTML</p>").send_bulk_mails

      expect(ActionMailer::Base.deliveries.count).to eq(5)
    end
  end
end
