class ClientAdminsController < ClientAdminBaseController
  def show
    # Note that we don't check for a divide-by-zero error since we should always have
    # at least one claimed user: the very client admin who is looking at this page.

    demo = current_user.demo

    @claimed_user_count = demo.claimed_user_count
    @with_phone_percentage = demo.claimed_user_with_phone_fraction.as_rounded_percentage
    @with_peer_invitation_fraction = demo.claimed_user_with_peer_invitation_fraction.as_rounded_percentage

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track("viewed page", {page_name: 'client admin dashboard'}.merge(current_user.data_for_mixpanel))

    @hc_hour = Highchart.chart(:hour, demo, DateTime.new(2012, 12, 15), nil, true, true)
    @hc_day  = Highchart.chart(:day,  demo, DateTime.new(2012, 12, 1), DateTime.new(2012, 12, 31), true, true)
    @hc_week = Highchart.chart(:week, demo, DateTime.new(2012, 12, 1), DateTime.new(2012, 12, 31), true, true)
  end
end
