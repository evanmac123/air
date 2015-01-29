class BillingNotificationMailer < ActionMailer::Base
  has_delay_mail

  default from: "billing_notification@airbo.com"

  def notify(user_id, board_id)
    @user = User.find(user_id)
    @board = Demo.find(board_id)

    mail(
      to: BILLING_INFORMATION_ENTERED_NOTIFICATION_ADDRESS
    )
  end
end
