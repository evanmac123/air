# frozen_string_literal: true

class SuggestedTileStatusMailer < BaseTilesDigestMailer
  EMAIL_TYPE = "Suggested Tile Digest"
  ACCEPTED_SUBJECT = "Your Tile Has Been Accepted!"
  POSTED_SUBJECT = "Your Tile Has Been Posted!"

  layout false

  def notify_accepted(user:, tile:)
    @user = user
    @demo = tile.demo

    @presenter = OpenStruct.new(
      general_site_url: digest_email_site_link(user, @demo.id, email_type: EMAIL_TYPE),
      cta_message: "Visit #{@demo.name}",
      email_heading: ACCEPTED_SUBJECT,
      custom_message:  "The Tile you suggested has been accepted. We’ll let you know when it’s posted."
    )

    mail(
      to: user.email_with_name,
      from: @demo.reply_email_address,
      subject: ACCEPTED_SUBJECT,
      template_path: "mailer",
      template_name: "system_email"
    )
  end

  def notify_posted(user:, tile:)
    @user = user
    @demo = tile.demo

    @presenter = OpenStruct.new(
      general_site_url: digest_email_site_link(user, @demo.id, email_type: EMAIL_TYPE),
      cta_message: "See your Tile",
      email_heading: POSTED_SUBJECT,
      custom_message:  "The administrator has posted your Tile."
    )

    mail(
      to: user.email_with_name,
      from: @demo.reply_email_address,
      subject: POSTED_SUBJECT,
      template_path: "mailer",
      template_name: "system_email"
    )
  end
end
