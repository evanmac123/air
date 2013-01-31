class ClientAdminsController < ClientAdminBaseController

  # todo But base class has: must_be_authorized_to :client_admin
  # must_be_authorized_to :site_admin
  # todo this?
  # before_filter :set_admin_page_flag, only: chart

  def show
    # Note that we don't check for a divide-by-zero error since we should always have
    # at least one claimed user: the very client admin who is looking at this page.

    demo = current_user.demo

    @claimed_user_count = demo.claimed_user_count
    @with_phone_percentage = demo.claimed_user_with_phone_fraction.as_rounded_percentage
    @with_peer_invitation_fraction = demo.claimed_user_with_peer_invitation_fraction.as_rounded_percentage

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track("viewed page", {page_name: 'client admin dashboard'}.merge(current_user.data_for_mixpanel))
  end

  def chart
    # Need to have appropriate instance variables set for the final client-admin page
    # (Still keep charting cordoned off in its own action because doubt this will always be the case)
    show

    @chart = Highchart.chart(current_user.demo,
                             params[:chart_interval],
                             params[:chart_start_date],
                             params[:chart_end_date],
                             params[:chart_plot_acts],
                             params[:chart_plot_users],
                             params[:chart_label_points])

    flash.now[:failure] = 'You did not supply the necessary plot parameters. Please check and try again.' if @chart.nil?

    render :show
  end
end
