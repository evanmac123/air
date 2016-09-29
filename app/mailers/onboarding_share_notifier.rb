class OnboardingShareNotifier < ActionMailer::Base
  default :from => "team@airbo.com"
  helper :email
  has_delay_mail

  def share(user, user_onboarding, sender)
    @user = user
    @user_onboarding = user_onboarding
    @sender = sender

    subject = "I think this could work for us."

    mail(:from    => sender.email,
         :to      => user.email,
         :subject => subject)
  end
end
