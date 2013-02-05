class ClientAdminsController < ClientAdminBaseController

  must_be_authorized_to :site_admin, only: :chart

  def show
    # Note that we don't check for a divide-by-zero error since we should always have
    # at least one claimed user: the very client admin who is looking at this page.

    demo = current_user.demo

    @claimed_user_count = demo.claimed_user_count
    @with_phone_percentage = demo.claimed_user_with_phone_fraction.as_rounded_percentage
    @with_peer_invitation_fraction = demo.claimed_user_with_peer_invitation_fraction.as_rounded_percentage

    params[:chart_start_date]   = (Time.now - 30.days).to_s(:chart_start_end_day)
    params[:chart_end_date]     = Time.now.to_s(:chart_start_end_day)
    params[:chart_plot_content] = 'Both'
    params[:chart_interval]     = 'Daily'
    params[:chart_label_points] = '1'

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track("viewed page", {page_name: 'client admin dashboard'}.merge(current_user.data_for_mixpanel))
  end

  def chart
    @chart = Highchart.chart(current_user.demo,
                             params[:chart_start_date],
                             params[:chart_end_date],
                             params[:chart_plot_content],
                             params[:chart_interval],
                             params[:chart_label_points])
  end
end
