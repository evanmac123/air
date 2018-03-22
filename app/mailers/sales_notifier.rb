class SalesNotifier < ApplicationMailer
  helper :email

  def lead_activated(user)
    @user = user

    mail(from: "Sales Notifier<notify@airbo.com>",
         to:   "team@airbo.com",
         subject: "#{user.email} Activated their account")
  end

  def lead_returned_via_invite_link(user)
    @user = user

    mail(from: "Sales Notifier<notify@airbo.com>",
         to:   "team@airbo.com",
         subject: "#{user.email} Clicked the invite link again")
  end
end
