class ClientAdmin::ReportsController < ClientAdminBaseController

  before_action :activity_email_ping

  def show
    current_user.remove_tile_email_report_notification
  end

  private

    def activity_email_ping
      if params[:email_type].present?
        properties = {
          email_type: params[:email_type],
          email_version: params[:email_version],
        }

        ping("Email clicked", properties, current_user)
      end
    end
end
