# frozen_string_literal: true

class BillingNotificationMailer < ApplicationMailer
  default from: "billing_notification@airbo.com"

  def notify(user_id, board_id)
    @user = User.find(user_id)
    @board = Demo.find(board_id)

    mail(
      to: "team@airbo.com"
    )
  end
end
