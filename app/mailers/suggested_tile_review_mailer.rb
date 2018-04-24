# frozen_string_literal: true

class SuggestedTileReviewMailer < ApplicationMailer
  layout false
  helper :email

  def notify_one(client_admin_id, demo_id, tile_sender_name, tile_sender_email)
    @user = User.find(client_admin_id)
    return nil unless @user.email.present?

    @demo = Demo.find(demo_id)

    @presenter = OpenStruct.new(
      general_site_url: submitted_tile_notifications_url(demo_id: demo_id),
      cta_message: "Review Tile",
      email_heading: "You have a new Tile in the <br>Suggestion Box!".html_safe,
      custom_message: "#{tile_sender_name} (#{tile_sender_email}) has submitted a Tile for your review."
    )

    mail(
      from: @demo.reply_email_address,
      to: @user.email,
      subject: "New Tile Submitted Needs Review",
      template_path: "mailer",
      template_name: "system_email"
    )
  end
end
