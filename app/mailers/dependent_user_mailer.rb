# frozen_string_literal: true

class DependentUserMailer < ApplicationMailer
  helper :email
  layout false
  default reply_to: "support@airbo.com"

  def notify(dependent_user, subject, body)
    @dependent_user = dependent_user
    return unless @dependent_user

    @demo = @dependent_user.demo
    @user = @dependent_user.primary_user
    @presenter = OpenStruct.new(
      dependent_email: @dependent_user.email,
      general_site_url: invitation_url(@dependent_user.invitation_code),
      email_heading: "You are invited to #{@demo.name}",
      custom_message: body,
      cta_message: "Accept"
    )

    mail(
      to: @presenter.dependent_email,
      subject: subject,
      from: "#{@user.name} via Airbo<#{@user.email}>",
      template_path: "mailer",
      template_name: "system_email"
    )
  end
end
