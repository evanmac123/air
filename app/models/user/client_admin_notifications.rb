module User::ClientAdminNotifications
  def set_tile_email_report_notification(board_id:)
    rdb[:client_admin_notifications][board_id][:tile_email_report].incr
  end

  def remove_tile_email_report_notification
    rdb[:client_admin_notifications][demo_id][:tile_email_report].del
  end

  def get_tile_email_report_notification_content
    rdb[:client_admin_notifications][demo_id][:tile_email_report].get
  end

  def has_tile_email_report_notification?
    get_tile_email_report_notification_content.present?
  end
end
