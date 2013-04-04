class EmailInfoRequest < ActiveRecord::Base
  def notify_the_ks_of_demo_request
    EmailInfoRequestNotifier.delay_mail(:info_requested, name, email, phone, comment)
  end
end
