class DependentUserMailer < ActionMailer::Base
  helper :email
  layout "mailer"
  default :reply_to => 'support@airbo.com'

	def notify(dependent_user_id, subject, body)
    @dependent_user = PotentialUser.find dependent_user_id
    return unless @dependent_user

    @dependent_email = @dependent_user.email
    @demo = @dependent_user.demo
    @user  = @dependent_user.primary_user
    @accept_url = invitation_url(@dependent_user.invitation_code)
    @subhead_text = body

		mail to: @dependent_email, subject: subject, from: "#{@user.name} via Airbo<#{@user.email}>"
  end
end
