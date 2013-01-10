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

=begin
    Salient Highchart notes:
    1)  Regarding the lazy_high_charts gem:
        It seems to be easier (albeit more wordy) to specify options using specific selectors, e.g.
          f.options[:xAxis][:categories] = [3, 5, 7]
          f.options[:xAxis][:title][:text] = 'x title'
        because it makes it easier to correlate what you see in the code with the highchart api docs.
        Unfortunately the second call results in an error on calling "[]= on nil"
        There is a bug description on this at: https://github.com/michelson/lazy_high_charts/pull/77
        and it seems that new releases were made after this issue was supposedly fixed, so I don't know
        why the fix isn't in the current version. Regardless, what you need to do is this:
          f.options[:xAxis][:title] = {}
          f.options[:xAxis][:title][:text] = 'x title'
        You know what - now I'm not so sure. I think it just might be a case of poor documentation
        regarding overriding options. Regardless, it cost me a bunch of time and it's still not clear.
    2)  What you plot is a 'series' and you can specify various options for it, e.g. 'name' and 'data'.
        You can also include any of the appropriate 'plotOptions' in the params. From the site doc:
          "In addition to the members listed below (for 'series'), any member of the 'plotOptions' for
           that specific type of plot can be added to a series individually. For example, even though
           a general 'lineWidth' is specified in 'plotOptions.series', an individual 'lineWidth'
           can be specified for each series.""
=end

    demo = Demo.find(13)
    acts = demo.acts

    min_date = acts.minimum(:created_at).to_date
    max_date = acts.maximum(:created_at).to_date

    p "******* min date is #{min_date} and max date is #{max_date}"
    p "***** Num acts is #{acts.length} and num days is #{(max_date - min_date).to_i}"

    hash = {}
    (min_date..max_date).each { |date| hash[date] = 0 }

    acts_per_day = acts.group_by { |act| act.created_at.to_date }
    acts_per_day.each { |k,v| acts_per_day[k] = v.length }

    hash.merge!(acts_per_day)

    p "**** number of days with non-zero acts is #{acts_per_day.keys.length}"
    p "**** number of days with all acts is #{hash.keys.length}"

    # 'sort' returns [ [k,v] [k,v] ... [k,v] ] sorted by keys, i.e. creation date
    # Pass to a 'series': k = creation date = x value ; v = num. acts for that day = y value
    #data = acts_per_day.sort
    data = hash.sort
    p data.inspect

    data.each { |point| point[0] = point[0].to_s(:short) }


    h = { second: '%H:%M:%S sec',
          minute: '%H:%M min',
          hour: '%H:%M hour',
          day: '%e of %b day',
          week: '%e of %b week',
          month: '%b of %y month',
          year: '%Y year'
        }

    @hc = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "H Engage Activity Graph For #{demo.name}")
      f.chart(zoomType: 'x')
      f.yAxis(min: 0, title: {text: 'Activities'})
      #f.xAxis(type: 'datetime', title: {text: 'Date'}, dateTimeLabelFormats: {day: '%e day %b', week: '%e day %b', month: '%b of %y month' })
      f.xAxis(type: 'datetime', title: {text: 'Date'})
      f.series(name: 'Number of activities', data: data, color: '#4D7A36',
               pointStart: min_date, pointInterval: 60 * 60 * 24)
    end
  end
end
