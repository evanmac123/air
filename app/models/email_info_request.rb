class EmailInfoRequest < ActiveRecord::Base
  def notify
    EmailInfoRequestNotifier.delay_mail(:info_requested, self)
  end
end
