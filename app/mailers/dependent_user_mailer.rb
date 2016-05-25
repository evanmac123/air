class DependentUserMailer < ActionMailer::Base
  helper :email
  layout "mailer"
  default :reply_to => 'support@airbo.com'

	def notify(demo_id, dependent_email, subject, body, user_id)
    @demo = Demo.find demo_id
    @user  = User.find user_id
    @accept_url = home_path
    @subhead_text = body

		mail to: dependent_email, subject: subject, from: "#{@user.name} via Airbo"
  end
end
