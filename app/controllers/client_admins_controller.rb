class ClientAdminsController < ClientAdminBaseController
  def show
    # Note that we don't check for a divide-by-zero error since we should 
    # always have at least one claimed user: the very client admin who is
    # looking at this page.

    demo = current_user.demo
    claimed_users = demo.users.claimed

    @claimed_user_count = demo.claimed_user_count
    @with_phone_percentage = demo.claimed_user_with_phone_fraction.as_rounded_percentage
    @with_peer_invitation_fraction = demo.claimed_user_with_peer_invitation_fraction.as_rounded_percentage

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track("viewed page", {page_name: 'client admin dashboard'}.merge(current_user.data_for_mixpanel))

    demo = Demo.find(13)

    # todo don't need 1st arg; one arg => hourly, two args => daily
    @hc_day  = demo.highchart(:daily, DateTime.new(2012, 12, 1), DateTime.new(2012, 12, 31))
    @hc_hour = demo.highchart(:hourly, DateTime.new(2012, 12, 15))
  end
end
