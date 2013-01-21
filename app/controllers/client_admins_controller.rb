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

  def chart
    @chart = Highchart.chart(current_user.demo,
                             params[:interval],
                             convert_date(params[:start_date]),
                             convert_date(params[:end_date]),
                             params[:acts],
                             params[:users],
                             params[:label_points])
    render :show
  end

  # todo Phil: Do we want to stash this somewhere, e.g. lib/monkey_patches/date_helper.rb ( => TESTS! )
  # Converts "day/month/year" to "month/day/year", e.g. 17/7/2013 to 7/17/2013
  def convert_date(date_string)
    date_string.sub(/(\d{1,2})\/(\d{1,2})\/(\d{1,4})/, '\2/\1/\3').to_datetime
  end
end
