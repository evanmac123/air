class ClientAdminsController < ClientAdminBaseController
  def show
    # Note that we don't check for a divide-by-zero error since we should always have
    # at least one claimed user: the very client admin who is looking at this page.

    demo = current_user.demo

    @claimed_user_count = demo.claimed_user_count
    @with_phone_percentage = demo.claimed_user_with_phone_fraction.as_rounded_percentage
    @with_peer_invitation_fraction = demo.claimed_user_with_peer_invitation_fraction.as_rounded_percentage

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track("viewed page", {page_name: 'client admin dashboard'}.merge(current_user.data_for_mixpanel))
  end

  # todo okay to add this method to this controller?
  def chart
    @chart = Highchart.chart(current_user.demo,
                             params[:chart_interval],
                             params[:chart_start_date],
                             params[:chart_end_date],
                             params[:chart_plot_acts],
                             params[:chart_plot_users],
                             params[:chart_label_points])
    render :show
  end
end
