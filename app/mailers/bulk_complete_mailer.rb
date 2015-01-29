class BulkCompleteMailer < ActionMailer::Base
  has_delay_mail

  helper :email
  default :to => Admin::BulkSatisfactionsController::REPORT_RECIPIENT,
          :from => "donotreply@airbo.com"

  def report(states)
    @states = states

    mail(:subject => "Bulk completion report")
  end
end
