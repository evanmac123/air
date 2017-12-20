require 'rails_helper'

describe TileUserNotificationMailer do
  let(:users) { FactoryBot.create_list(:user, 2) }
  let(:tile) { FactoryBot.create(:tile) }
  let(:tile_user_notification) { TileUserNotification.create(tile: tile, creator: users.first, subject: "A SUBJECT", message: "A MESSAGE") }

  describe "#notify_all" do
    it "asks itself to notify_one for each recipient and updates the tile_user_notification delivered_at" do
      tile_user_notification.expects(:users).returns(users)

      TileUserNotificationMailer.expects(:delay).with(queue: TileUserNotification::DELAYED_JOB_QUEUE).twice.returns(TileUserNotificationMailer)

      TileUserNotificationMailer.expects(:notify_one).with(user: users.first, tile_user_notification: tile_user_notification)

      TileUserNotificationMailer.expects(:notify_one).with(user: users.last, tile_user_notification: tile_user_notification)

      TileUserNotificationMailer.notify_all(tile_user_notification: tile_user_notification)

      expect(tile_user_notification.delivered_at).to_not eq(nil)
    end
  end

  describe "#notify_one" do
    it "does nothing if the passed in users has no email" do
      result = TileUserNotificationMailer.notify_one(user: User.new(email: nil), tile_user_notification: tile_user_notification)

      expect(result.class).to eq(ActionMailer::Base::NullMail)
    end

    it "delivers email to user" do
      user = users.last
      email = TileUserNotificationMailer.notify_one(user: user, tile_user_notification: tile_user_notification)

      expect(email.subject).to eq("A SUBJECT")
      expect(email.from).to eq([tile.demo.reply_email_address(false)])
      expect(email.to).to eq([user.email])
    end

    it "adds custom X-SMTPAPI header" do
      user = users.last
      mail = TileUserNotificationMailer.notify_one(user: user, tile_user_notification: tile_user_notification)

      x_smtpapi_header = JSON.parse(mail.header["X-SMTPAPI"].value)

      custom_unique_args = tile_user_notification.demo.data_for_mixpanel(user: user).merge({
        subject: tile_user_notification.subject,
        notification_id: tile_user_notification.id,
        email_type: "Tile Push Message"
      }).to_json

      expect(x_smtpapi_header["category"]).to eq("Tile Push Message")
      expect(x_smtpapi_header["unique_args"]).to eq(JSON.parse(custom_unique_args))
    end
  end
end
