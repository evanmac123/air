class UserSettingsChangeLogMailer < ApplicationMailer
  helper :email
  layout false

  def change_email(change_log_id)
    change_log = UserSettingsChangeLog.find(change_log_id)
    @user = User.find(change_log.user_id)
    return unless @user && change_log
    @demo = @user.demo

    @presenter = OpenStruct.new(
      general_site_url: change_email_url(token: change_log.email_token),
      cta_message: "Confirm",
      email_heading: "It looks like you've changed your email address in #{@demo.name} to #{change_log.email}",
      custom_message: "Please click below to confirm the change. If you didn't didn't make this change, contact support@airbo.com."
    )

    mail(
      to: @user.email_with_name,
      from: "Airbo <support@ourairbo.com>",
      subject:  "Email Change Confirmation",
      template_path: "mailer",
      template_name: "system_email"
    )
  end
end
