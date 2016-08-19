class EmailInfoRequest < ActiveRecord::Base
  def notify_sales_of_demo_request
    EmailInfoRequestNotifier.delay_mail(:info_requested, self)
  end

  def notify_sales_of_signup_request
    EmailInfoRequestNotifier.delay_mail(:signup_requested, self)
  end
end
