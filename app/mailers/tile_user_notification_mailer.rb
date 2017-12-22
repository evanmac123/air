class TileUserNotificationMailer < ApplicationMailer
  helper :email
  layout 'mailer'

  def self.notify_all(tile_user_notification:)
    recipients = tile_user_notification.users

    recipients.each do |user|
      TileUserNotificationMailer.delay(queue: TileUserNotification::DELAYED_JOB_QUEUE).notify_one(user: user, tile_user_notification: tile_user_notification)
    end

    tile_user_notification.update_attributes(delivered_at: Time.current)
  end

  def notify_one(user:, tile_user_notification:)
    @user = user
    return nil unless @user && @user.email.present?

    @demo = tile_user_notification.demo
    @creator = tile_user_notification.creator
    @message = tile_user_notification.interpolated_message(user: @user)

    x_smtpapi_unique_args = @demo.data_for_mixpanel(user: @user).merge({
      subject: tile_user_notification.subject,
      notification_id: tile_user_notification.id,
      email_type: "Tile Push Message"
    })

    set_x_smtpapi_headers(category: "Tile Push Message", unique_args: x_smtpapi_unique_args)

    mail(to: @user.email_with_name, from: tile_user_notification.from_email, subject: tile_user_notification.subject, reply_to: 'support@airbo.com')
  end
end
