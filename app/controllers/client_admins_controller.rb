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

    # ============= My New Stuff ===============

    acts = Demo.find(13).acts
    h = acts.group_by(&:group_by_date)
    h.each { |k,v| h[k] = v.length }
    #data = h.collect { |k,v| [k,v] }
    data = h.sort  # returns [ [k,v] [k,v] ... [k,v] ] sorted by keys, i.e. creation date

    min_date = acts.minimum(:created_at).to_date
    max_date = acts.maximum(:created_at).to_date

    p "******* min is #{min_date} and max is #{max_date}"

    #ids = acts.pluck :id
    #plain_ids = ids.map { |id| id + 20 }

    @hc = LazyHighCharts::HighChart.new('graph') do |f|
      #f.series(name: 'Act ID', data: ids, point_start: min_date.to_time.to_i, color: '#4D7A36')
      #f.options[:plotOptions][:line][:pointStart] = min_date
      #f.plotOptions(:line][:pointStart] = min_date
      #f.options[:plotOptions][:line][:pointInterval] =  24 * 3600 * 1000 # one day

      f.chart(zoomType: 'x')
      f.xAxis(type: 'datetime')
      f.series(name: 'Number of acts per day', data: data, color: '#4D7A36', pointStart: min_date.to_datetime.utc)
      #f.series(name: 'Number of acts per day', data: data, color: '#4D7A36', pointStart: min_date, pointInterval: 24 * 3600 * 1000)
    end
  end
end
