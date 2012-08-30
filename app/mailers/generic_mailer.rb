require 'delayed/syck_ext' # to fix retarded YAML serialization of 
                           # GenericMailer::BulkSender module

class GenericMailer < ActionMailer::Base
  include EmailInterpolations::InvitationUrl

  helper :email

  def send_message(user_id, subject, plain_text, html_text)
    @user = User.find(user_id)

    _invitation_url = invitation_url(@user.invitation_code)

    @html_text = interpolate_invitation_url(_invitation_url, html_text).html_safe
    @plain_text = interpolate_invitation_url(_invitation_url, plain_text).html_safe

    from_string = @user.demo.email.present? ? @user.demo.reply_email_address : "H Engage <play@playhengage.com>"

    while(@plain_text !~ /\n\n$/)
      @plain_text += "\n"
    end

    mail(
      :to      => @user.email,
      :subject => subject,
      :from    => from_string
    ) 
  end

  module BulkSender
    def self.bulk_generic_messages(user_ids, subject, plain_text, html_text)
      user_ids.each do |user_id|
        GenericMailer.delay.send_message(user_id, subject, plain_text, html_text)
      end
    end
  end
end
