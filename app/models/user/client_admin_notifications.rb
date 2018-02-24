# frozen_string_literal: true

module User::ClientAdminNotifications
  def set_tile_email_report_notification(board_id:)
    self.redis[:client_admin_notifications][board_id][:tile_email_report].call(:incr)
  end

  def remove_tile_email_report_notification
    self.redis[:client_admin_notifications][demo_id][:tile_email_report].call(:del)
  end

  def get_tile_email_report_notification_content
    self.redis[:client_admin_notifications][demo_id][:tile_email_report].call(:get)
  end

  def has_tile_email_report_notification?
    get_tile_email_report_notification_content.present?
  end
end
