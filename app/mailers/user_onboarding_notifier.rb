class UserOnboardingNotifier < ActionMailer::Base
  default from: "team@airbo.com"
  helper :email

  def notify_all(user_onboarding, colleagues)
    referrer = user_onboarding.user
    organization = user_onboarding.organization
    colleague_emails = parse(colleagues)

    colleague_emails.each do |email|
      UserOnboardingNotifier.delay.notify(email, referrer, organization)
    end
  end

  def notify(email, referrer, organization)
    @email = email
    @referrer = referrer
    @organization = organization

    subject = "I think this could work for us."

    mail(:from    => @referrer.email,
         :to      => @email,
         :subject => subject)
  end

  private

    def parse(colleagues)
      colleagues.gsub(/\s+/, "").split(",")
    end

    def valid?(email)
     valid = '[A-Za-z\d.+-]+'
     (email =~ /#{valid}@#{valid}\.#{valid}/) == 0
    end
end
