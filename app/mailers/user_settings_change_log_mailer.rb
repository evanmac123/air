class UserSettingsChangeLogMailer < ActionMailer::Base
  helper :email
  layout "mailer"
  default :reply_to => 'support@airbo.com'

	def change_email(change_log_id)
    @change_log = UserSettingsChangeLog.find change_log_id
    @user = User.find @change_log.user_id
    return if !@user || !@change_log

    @confirm_url = change_email_url(token: @change_log.email_token)

		mail to: @user.email, subject: "Email was changed", from: "Airbo <support@ourairbo.com>>"
  end
end
