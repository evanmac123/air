require 'rails_helper'

RSpec.describe TileUserNotificationBulkMailJob, type: :job do
  let(:users) { FactoryBot.create_list(:user, 2) }
  let(:tile) { FactoryBot.create(:tile) }
  let(:tile_user_notification) { TileUserNotification.create(tile: tile, creator: users.first, subject: "A SUBJECT", message: "A MESSAGE") }

  describe "#perform" do
    it "asks itself to notify_one for each recipient and updates the tile_user_notification delivered_at" do
      tile_user_notification.expects(:users).returns(users)

      mock_delivery = ActionMailer::Base::NullMail.new

      TileUserNotificationMailer.expects(:notify_one).with(user: users.first, tile_user_notification: tile_user_notification).returns(mock_delivery)

      TileUserNotificationMailer.expects(:notify_one).with(user: users.last, tile_user_notification: tile_user_notification).returns(mock_delivery)

      TileUserNotificationBulkMailJob.perform_now(tile_user_notification: tile_user_notification)

      expect(tile_user_notification.delivered_at).to_not eq(nil)
    end
  end
end
