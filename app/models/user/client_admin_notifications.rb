module User::ClientAdminNotifications
  def set_tile_email_report_notification
    rdb[:client_admin_notifications][:tile_email_report].incr
  end

  def remove_tile_email_report_notification
    rdb[:client_admin_notifications][:tile_email_report].del
  end

  def get_tile_email_report_notification_content
    rdb[:client_admin_notifications][:tile_email_report].get
  end

  def has_tile_email_report_notification?
    rdb[:client_admin_notifications][:tile_email_report].get.present?
  end
end
