class GenericMailer < ActionMailer::Base
  include EmailInterpolations::InvitationUrl
  include EmailInterpolations::TileDigestUrl

  helper :email
  has_delay_mail

  layout 'mailer'

  default reply_to: 'support@air.bo'

  def send_message(demo_id, user_id, subject, plain_text, html_text)
    @user = User.find(user_id)
    return unless @user.email.present?

    _invitation_url = invitation_url(@user.invitation_code, demo_id: demo_id)

    @html_text = interpolate_invitation_url(_invitation_url, html_text).html_safe
    @plain_text = interpolate_invitation_url(_invitation_url, plain_text).html_safe
    @html_text = interpolate_tile_digest_url(@user, demo_id, @html_text)
    @plain_text = interpolate_tile_digest_url(@user, demo_id, @plain_text)

    @demo = demo = Demo.find(demo_id)
    from_string = demo.email.present? ? demo.reply_email_address : "Airbo <play@ourairbo.com>"

    while(@plain_text !~ /\n\n$/)
      @plain_text += "\n"
    end

    mail(
      :to      => @user.email,
      :subject => subject,
      :from    => from_string
    )
  end

  class BulkSender
    def initialize(demo_id, user_ids, subject, plain_text, html_text)
      @demo_id = demo_id
      @user_ids = user_ids
      @subject = subject
      @plain_text = plain_text
      @html_text = html_text
    end

    def send_bulk_mails
      @user_ids.each do |user_id|
        GenericMailer.delay_mail(:send_message, @demo_id, user_id, @subject, @plain_text, @html_text)
      end
    end
  end
end
