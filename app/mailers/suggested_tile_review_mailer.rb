class SuggestedTileReviewMailer < ApplicationMailer
  layout "mailer"
  helper :email

  def notify_one(client_admin_id, demo_id, tile_sender_name, tile_sender_email)
    @user = User.find(client_admin_id)
    return nil unless @user.email.present?

    @demo = Demo.find(demo_id)
    @name = tile_sender_name
    @email = tile_sender_email
    @link = submitted_tile_notifications_url(demo_id: demo_id)

    mail  from:     @demo.reply_email_address,
          to:       @user.email,
          subject:  "New Tile Submitted Needs Review"
  end
end
