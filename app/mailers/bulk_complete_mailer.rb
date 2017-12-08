class BulkCompleteMailer < ApplicationMailer
  has_delay_mail

  helper :email
  default :to => "admin@airbo.com",
          :from => "donotreply@airbo.com"

  def report(states)
    @states = states

    mail(:subject => "Bulk completion report")
  end
end
