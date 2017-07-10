class ClientAdmin::NotificationsManager
  def self.set_tile_email_report_notifications(board:)
    board.client_admin.each do |user|
      user.set_tile_email_report_notification(board_id: board.id)
    end
  end
end
