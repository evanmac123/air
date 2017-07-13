class SuggestedTileStatusMailer < BaseTilesDigestMailer
  EMAIL_TYPE = "Suggested Tile Email"
  ACCEPTED_SUBJECT = "Your Tile Has Been Accepted!"
  POSTED_SUBJECT = "Your Tile Has Been Posted!"

  layout "mailer"

  def notify(message_type:, user:, tile:)
    @user = user
    @tile = tile
    @demo = tile.demo
    @subject = get_subject(message_type: message_type)
    @subhead_text = get_subhead_text(message_type: message_type)
    @button_text = get_button_text(board_name: @demo.name, message_type: message_type)
    @link = email_site_link(@user, @demo, false, EMAIL_TYPE)

    mail to: @user.email_with_name, from: @demo.reply_email_address, subject: @subject
  end

  private

    def get_subject(message_type:)
      if message_type == :accepted
        ACCEPTED_SUBJECT
      elsif message_type == :posted
        POSTED_SUBJECT
      end
    end

    def get_button_text(board_name:, message_type:)
      if message_type == :accepted
        "Visit #{board_name}"
      elsif message_type == :posted
        "See your Tile"
      end
    end

    def get_subhead_text(message_type:)
      if message_type == :accepted
        "The Tile you suggested has been accepted. We’ll let you know when it’s posted."
      elsif message_type == :posted
        "The administrator has posted your Tile."
      end
    end
end
