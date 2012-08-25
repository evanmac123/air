class BulkCompleteMailer < ActionMailer::Base
  helper :email
  default :to => Admin::BulkSatisfactionsController::REPORT_RECIPIENT,
          :from => "donotreply@hengage.com"

  def report(states)
    @states = states

    mail(:subject => "Bulk completion report")
  end
end
