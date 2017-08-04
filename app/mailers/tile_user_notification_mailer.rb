class TileUserNotificationMailer < ActionMailer::Base

  def notify_all(tile_user_notification:)
    recipients = tile_user_notification.users

    recipients.each do |user|
      TileUserNotificationMailer.delay(queue: TileUserNotification::DELAYED_JOB_QUEUE).notify_one(user: user, tile_user_notification: tile_user_notification)
    end

    tile_user_notification.update_attributes(delivered_at: Time.now)
  end

  def notify_one(user:, tile_user_notification:)
    @user = user
    return nil unless @user && @user.email.present?

    @creator = tile_user_notification.creator
    @tile_user_notification = tile_user_notification

    mail  to: @user.email_with_name, from: tile_user_notification.from_email, subject: tile_user_notification.subject
  end
end
