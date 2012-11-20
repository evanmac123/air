class ClaimTroubleMailer < ActionMailer::Base
  has_delay_mail

  helper :email
  default from: "noreply@hengage.com",
          to:   "supporters@hengage.com"

  def notify_admins(users)
    @users = users
    mail :subject => "Details on someone who may request help in claiming an account"
  end
end
