class TileUserNotificationBulkMailJob < ActiveJob::Base
  queue_as :bulk_mail

  def perform(tile_user_notification:)
    recipients = tile_user_notification.users

    recipients.each do |user|
      TileUserNotificationMailer.notify_one(user: user, tile_user_notification: tile_user_notification).deliver_later
    end

    tile_user_notification.update_attributes(delivered_at: Time.current)
  end
end
