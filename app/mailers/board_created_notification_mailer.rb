class BoardCreatedNotificationMailer < ApplicationMailer
  ADDRESS_TO_NOTIFY = (ENV['BOARD_CREATED_NOTIFICATION_ADDRESS']) || 'kate@airbo.com'

  default from: "notify@airbo.com"
  default to:   ADDRESS_TO_NOTIFY

  def notify(user_id, board_id)
    @user = User.find(user_id)
    @board = Demo.find(board_id)

    mail subject: "New Board Created"
  end
end
