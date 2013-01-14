module Highcharts

=begin

  Regarding the LazyHighCharts gem
  ================================

  It's arguably clearer (albeit more wordy) to specify options using specific selectors, e.g.
    hc.options[:xAxis][:categories] = [3, 5, 7]
    hc.options[:xAxis][:title][:text] = 'x title'
  because it makes it easier to correlate what you see in the code with the highchart api docs.

  The first stmt. works, but the second stmt. results in a calling "[]= on nil" error.
  There is a bug description on this at: https://github.com/michelson/lazy_high_charts/pull/77
  The doc implies that subsequent releases incorporated a bug fix, but that doesn't seem to be the case.
  Regardless, if you want to do it that way you need to do is this for the second stmt:
    hc.options[:xAxis][:title] = {}
    hc.options[:xAxis][:title][:text] = 'x title'

  Regarding the Highcharts API
  ============================

  What you plot is a 'series', which you specify various options for, e.g. 'name' and 'data'.

  You can also include any of the appropriate 'plotOptions' as part of the 'series' params.
  Instead of duplicating params between 'all' and 'unique' (and future) graphs, we specify same-value
  params as part of the 'plotOptions' and then (if needed) override them in the individual 'series' params.

  Zooming is disabled because a) the K's never used it and (b) if allowed => should keep the begin- and end-date
  controls in synch with it, which would be a pain. To enable zooming: hc.chart(zoomType: 'x')

  To change the labels on the X-axis:
    hc.xAxis(dateTimeLabelFormats: {day: 'This be the day: %e', week: 'This be the month: %b'})
  Note that milliseconds are also rendered by default for datetimes (the site's doc doesn't mention this and it
  makes you think something is wrong with the labels if you're not aware of it.) (Guess what I wasted time on.)
  The site lists the default formats, however, it doesn't list the time/date patterns you can use. Here they are:
    %a: Short weekday, like 'Mon'.
    %A: Long weekday, like 'Monday'.
    %d: Two digit day of the month, 01 to 31.
    %e: Day of the month, 1 through 31.
    %b: Short month, like 'Jan'.
    %B: Long month, like 'January'.
    %m: Two digit month number, 01 through 12.
    %y: Two digits year, like 09 for 2009.
    %Y: Four digits year, like 2009.
    %H: Two digits hours in 24h format, 00 through 23.
    %I: Two digits hours in 12h format, 00 through 11.
    %l (Lower case L): Hours in 12h format, 1 through 11.
    %M: Two digits minutes, 00 through 59.
    %p: Upper case AM or PM.
    %P: Lower case AM or PM.
    %S: Two digits seconds, 00 through 59
=end

  def highchart(type, start_date, end_date = nil)
    raise ArgumentError.new("Invalid Highchart Type: #{type.to_s}") unless ([:daily, :hourly].include?(type))

    # todo need to handle this case
    return nil if acts.count == 0

    all_acts_per_day = {}
    unique_acts_per_day = {}

    # Pre-populate hash of all-days-to-plot with 0 acts for that day
    # Note: Can't group by time because each distinct hour/minute/second would warrant its own group
    # Note: Can't group by day because range can overlap => duplicate day numbers
    date_range = start_date..end_date
    date_range.each { |date| all_acts_per_day[date.to_date] = unique_acts_per_day[date.to_date] = 0 }

    num_all_acts_per_day = {}
    num_unique_acts_per_day = {}

    # todo embellish this comment
    # AR dates are UTC time. Need to reject dbase entries like this "created_at: 2012-12-10 02:37:36" because
    # if you do an 'act.created_at' for that time you get "Sun, 09 Dec 2012 21:37:36 EST -05:00", which would
    # not fall in the 10..20 range. Note that the class of 'act.created_at' is actually 'ActiveSupport::TimeWithZone'
    # thus you need to convert it if you want to test range inclusion.
    # Here's the fucked-up thing: range is expressed in DateTime's, but if you do an 'act.created_at.to_datetime'
    # then *nothing* gets rejected.
    plot_acts = acts.where(created_at:(date_range)).reject { |act| not date_range.include?(act.created_at.to_date) }

    raw_acts_per_day = plot_acts.group_by { |act| act.created_at.to_date }

    raw_acts_per_day.each do |k,v|
      num_all_acts_per_day[k] = v.length

      by_user = v.group_by &:user
      num_unique_acts_per_day[k] = by_user.keys.length
    end

    # 'merge' => any acts for a given day replace the initial '0' acts for that day, while
    #  keeping initial '0' for non-act days so have something to plot for each day.
    # 'sort' => by keys, i.e. creation date. Returns array of the form: [ [k,v], [k,v], [k,v], [k,v] ]
    all_data = all_acts_per_day.merge!(num_all_acts_per_day).sort
    unique_data = unique_acts_per_day.merge!(num_unique_acts_per_day).sort

    # Change the 'k' value (i.e. the date) for each [k,v] point to a string => Highcharts will not
    # use this value as the x-coordinate, but instead will treat it as the name of the point.
    # (Don't need it to be a true x/date value because we always plot one point per x-axis interval.)
    (all_data + unique_data).each { |point| point[0] = point[0].to_s(:short) }

    LazyHighCharts::HighChart.new do |hc|
      # Initialize the Highcharts default color array. Colors used in order and recycled => start off with H-Engage green
      # (Tried a whole bunch of ways to set these colors and this is the only way that worked. Beats me.)
      hc.colors
      hc.options[:colors][0] = '#4D7A36'
      hc.options[:colors][1] = '#F00'

      hc.title(text: "H Engage #{name} Chart")
      hc.subtitle(text: "#{start_date.to_s(:long)} thru #{end_date.to_s(:long)}")

      hc.chart(zoomType: 'x')

      hc.xAxis(title: {text: 'Date'}, type: 'datetime')
      hc.yAxis(title: {text: 'Acts'}, min: 0)

      # Point interval is (number of seconds in) one day.
      # (LazyHighCharts gem converts to number of milliseconds, which Highcharts uses.)
      hc.plotOptions(line: {pointStart: start_date.to_date, pointInterval: 60 * 60 * 24})

      hc.series(name: 'All Acts', data: all_data)
      hc.series(name: 'Unique Acts', data: unique_data)
    end
  end
end