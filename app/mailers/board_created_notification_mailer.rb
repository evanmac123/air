# frozen_string_literal: true

class BoardCreatedNotificationMailer < ApplicationMailer
  ADDRESS_TO_NOTIFY = "team@airbo.com"

  default from: "notify@airbo.com"
  default to:   ADDRESS_TO_NOTIFY

  def notify(user_id, board_id)
    @user = User.find(user_id)
    @board = Demo.find(board_id)

    mail subject: "New Board Created"
  end
end
