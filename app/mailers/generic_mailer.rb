# frozen_string_literal: true

class GenericMailer < ApplicationMailer
  include EmailInterpolations::InvitationUrl
  include EmailInterpolations::TileDigestUrl

  helper :email

  layout false

  default reply_to: "support@airbo.com"

  def send_message(demo_id, user_id, subject, html_text, potential_users = nil)
    unless potential_users
      @user = User.find(user_id)
    else
      @user = PotentialUser.find(user_id)
    end
    return unless @user.email.present?

    invitation_url = invitation_url(@user.invitation_code, demo_id: demo_id)

    custom_message = interpolate_invitation_url(invitation_url, html_text).html_safe
    custom_message = interpolate_tile_digest_url(@user, demo_id, custom_message)

    @demo = demo = Demo.find(demo_id)
    from_string = demo.email.present? ? demo.reply_email_address : "Airbo <play@ourairbo.com>"

    @presenter = OpenStruct.new(
      general_site_url: invitation_url,
      custom_message: custom_message
    )

    mail(
      to: @user.email,
      subject: subject,
      from: from_string,
      template_path: "mailer",
      template_name: "system_email"
    )
  end

  class BulkSender
    def initialize(demo_id, user_ids, subject, html_text, potential_users = false)
      @demo_id = demo_id
      @user_ids = user_ids
      @subject = subject
      @html_text = html_text
      @potential_users = potential_users
    end

    def send_bulk_mails
      @user_ids.each do |user_id|
        GenericMailer.send_message(@demo_id, user_id, @subject, @html_text, @potential_users).deliver_later
      end
    end
  end
end
