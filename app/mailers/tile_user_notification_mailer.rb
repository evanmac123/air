class TileUserNotificationMailer < ApplicationMailer
  helper :email
  layout nil

  def notify_one(user:, tile_user_notification:)
    @user = user
    return nil unless @user && @user.email.present?

    @demo = tile_user_notification.demo
    @presenter = OpenStruct.new(
      creator: tile_user_notification.creator,
      custom_message: tile_user_notification.interpolated_message(user: @user),
      general_site_url: digest_email_site_link(@user, @demo.id)
    )

    x_smtpapi_unique_args = @demo.data_for_mixpanel(user: @user).merge({
      subject: tile_user_notification.subject,
      notification_id: tile_user_notification.id,
      email_type: "Tile Push Message"
    })

    set_x_smtpapi_headers(category: "Tile Push Message", unique_args: x_smtpapi_unique_args)

    mail(to: @user.email_with_name, from: tile_user_notification.from_email, subject: tile_user_notification.subject, reply_to: 'support@airbo.com')
  end
end
