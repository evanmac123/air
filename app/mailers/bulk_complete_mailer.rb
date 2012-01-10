class BulkCompleteMailer < ActionMailer::Base
  default :to => Admin::BulkSatisfactionsController::REPORT_RECIPIENT

  def report(states)
    @states = states

    mail(:subject => "Bulk completion report")
  end
end
