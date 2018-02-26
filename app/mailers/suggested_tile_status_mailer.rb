# frozen_string_literal: true

class SuggestedTileStatusMailer < BaseTilesDigestMailer
  EMAIL_TYPE = "Suggested Tile Email"
  ACCEPTED_SUBJECT = "Your Tile Has Been Accepted!"
  POSTED_SUBJECT = "Your Tile Has Been Posted!"

  layout "mailer"

  def notify_accepted(user:, tile:)
    @demo = tile.demo
    @subject = ACCEPTED_SUBJECT
    @subhead_text = "The Tile you suggested has been accepted. We’ll let you know when it’s posted."
    @button_text = "Visit #{@demo.name}"
    @link = digest_email_site_link(user, @demo.id, EMAIL_TYPE)

    mail to: user.email_with_name, from: @demo.reply_email_address, subject: @subject
  end

  def notify_posted(user:, tile:)
    @demo = tile.demo
    @subject = POSTED_SUBJECT
    @subhead_text = "The administrator has posted your Tile."
    @button_text = "See your Tile"
    @link = digest_email_site_link(user, @demo.id, EMAIL_TYPE)

    mail to: user.email_with_name, from: @demo.reply_email_address, subject: @subject
  end
end
