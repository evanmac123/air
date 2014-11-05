class ClientAdminsController < ClientAdminBaseController

  def show
    respond_to do |format|
      format.html do
        demo = current_user.demo

        @claimed_user_count = demo.claimed_user_count
        @with_phone_percentage = demo.claimed_user_with_phone_fraction.as_rounded_percentage
        @with_peer_invitation_fraction = demo.claimed_user_with_peer_invitation_fraction.as_rounded_percentage
        @demo = demo

        params[:chart_start_date]   = (Time.now - 30.days).to_s(:chart_start_end_day)
        params[:chart_end_date]     = Time.now.to_s(:chart_start_end_day)
        params[:chart_plot_content] = 'Both'
        params[:chart_interval]     = 'Weekly'
        params[:chart_label_points] = '0'

        ping_page('Manage - Activity', current_user)

        render template: 'client_admin/show'
      end

      format.js do
        @chart = Highchart.chart(current_user.demo,
                                 params[:chart_start_date],
                                 params[:chart_end_date],
                                 params[:chart_plot_content],
                                 params[:chart_interval],
                                 params[:chart_label_points])

        render template: '/client_admin/charts/chart'
      end
    end
  end
end
