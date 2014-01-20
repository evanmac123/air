class BulkCompleteMailer < ActionMailer::Base
  has_delay_mail

  helper :email
  default :to => Admin::BulkSatisfactionsController::REPORT_RECIPIENT,
          :from => "donotreply@air.bo"

  def report(states)
    @states = states

    mail(:subject => "Bulk completion report")
  end
end
