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

  #def highchart(type, start_date, end_date = nil)
  #  raise ArgumentError.new("Invalid Highchart Type: #{type.to_s}") unless ([:daily, :hourly].include?(type))
  #
  #  # todo need to handle this case
  #  return nil if acts.count == 0
  #
  #  all_acts_per_day = {}
  #  unique_acts_per_day = {}
  #
  #  all_acts_per_hour = {}
  #  unique_acts_per_hour = {}
  #
  #  # Pre-populate hash of all-days-to-plot with 0 acts for that day
  #  # Note: Can't group by time because each distinct hour/minute/second would warrant its own group
  #  # Note: Can't group by day because range can overlap => duplicate day numbers
  #  date_range = start_date..end_date unless type == :hourly
  #  date_range.each { |date| all_acts_per_day[date.to_date] = unique_acts_per_day[date.to_date] = 0 } unless type == :hourly
  #
  #  start = start_date.beginning_of_day
  #  stop = start_date.end_of_day
  #
  #  while stop > start
  #    all_acts_per_hour[start.hour] = unique_acts_per_hour[start.hour] = 0
  #    start += 1.hour
  #  end
  #
  #  start = start_date.beginning_of_day  # Need to reset
  #  hour_range = start..stop
  #
  #  num_all_acts_per_day = {}
  #  num_unique_acts_per_day = {}
  #
  #  num_all_acts_per_hour = {}
  #  num_unique_acts_per_hour = {}
  #
  #  # todo embellish this comment
  #  # AR dates are UTC time. Need to reject dbase entries like this "created_at: 2012-12-10 02:37:36" because
  #  # if you do an 'act.created_at' for that time you get "Sun, 09 Dec 2012 21:37:36 EST -05:00", which would
  #  # not fall in the 10..20 range. Note that the class of 'act.created_at' is actually 'ActiveSupport::TimeWithZone'
  #  # thus you need to convert it if you want to test range inclusion.
  #  # Here's the fucked-up thing: range is expressed in DateTime's, but if you do an 'act.created_at.to_datetime'
  #  # then *nothing* gets rejected.
  #  plot_acts = acts.where(created_at:(date_range)) unless type == :hourly
  #  #plot_acts = acts.where(created_at:(date_range)).reject { |act| not date_range.include?(act.created_at.to_date) } unless type == :hourly
  #  hour_acts = acts.where(created_at:(hour_range))  # todo need something like this? : .reject { |act| not date_range.include?(act.created_at.to_date) }
  #
  #  raw_acts_per_day = plot_acts.group_by { |act| act.created_at.to_date } unless type == :hourly
  #  raw_acts_per_hour = hour_acts.group_by { |act| act.created_at.hour }
  #
  #  raw_acts_per_day.each do |k,v|
  #    num_all_acts_per_day[k] = v.length
  #
  #    by_user = v.group_by &:user
  #    num_unique_acts_per_day[k] = by_user.keys.length
  #  end unless type == :hourly
  #
  #  raw_acts_per_hour.each do |k,v|
  #    num_all_acts_per_hour[k] = v.length
  #
  #    by_user = v.group_by &:user
  #    num_unique_acts_per_hour[k] = by_user.keys.length
  #  end
  #
  #  # 'merge' => any acts for a given day replace the initial '0' acts for that day, while
  #  #  keeping initial '0' for non-act days so have something to plot for each day.
  #  # 'sort' => by keys, i.e. creation date. Returns array of the form: [ [k,v], [k,v], [k,v], [k,v] ]
  #  all_data = all_acts_per_day.merge!(num_all_acts_per_day).sort unless type == :hourly
  #  unique_data = unique_acts_per_day.merge!(num_unique_acts_per_day).sort unless type == :hourly
  #
  #  all_hour_data = all_acts_per_hour.merge!(num_all_acts_per_hour).sort
  #  unique_hour_data = unique_acts_per_hour.merge!(num_unique_acts_per_hour).sort
  #
  #  # Change the 'k' value (i.e. the date) for each [k,v] point to a string => Highcharts will not
  #  # use this value as the x-coordinate, but instead will treat it as the name of the point.
  #  # (Don't need it to be a true x/date value because we always plot one point per x-axis interval.)
  #  # todo if don't have option to display every other point => just pass array of y values
  #  (all_data + unique_data).each_with_index { |point, i| i.even? ? point[0] = '' : point[0] = point[1].to_s } unless type == :hourly
  #  (all_hour_data + unique_hour_data).each_with_index { |point, i| i.even? ? point[0] = '' : point[0] = point[1].to_s }
  #
  #  if (type == :daily)
  #    LazyHighCharts::HighChart.new do |hc|
  #      # Initialize the Highcharts default color array. Colors used in order and recycled => start off with H-Engage green
  #      # (Tried a whole bunch of ways to set these colors and this is the only way that worked. Beats me.)
  #      hc.colors
  #      hc.options[:colors][0] = '#4D7A36'
  #      hc.options[:colors][1] = '#F00'
  #
  #      hc.title(text: "H Engage #{name} Chart")
  #      hc.subtitle(text: "#{start_date.to_s(:long)} thru #{end_date.to_s(:long)}")
  #
  #      hc.chart(zoomType: 'x')
  #
  #      hc.xAxis(title: {text: 'Date'}, type: 'datetime')
  #      hc.yAxis(title: {text: 'Acts'}, min: 0)
  #
  #      # Point interval is (number of seconds in) one day.
  #      # (LazyHighCharts gem converts to number of milliseconds, which Highcharts uses.)
  #      # todo if don't have option to display every other point => remove 'formatter' function
  #      hc.plotOptions(line: {pointStart: start_date.to_date, pointInterval: 60 * 60 * 24,
  #                            dataLabels: {enabled: true, fontWeight: 'bold', formatter: %|function() { return this.point.name; }|.js_code}})
  #
  #      hc.series(name: 'All Acts', data: all_data)
  #      hc.series(name: 'Unique Acts', data: unique_data)
  #    end
  #  else
  #    LazyHighCharts::HighChart.new do |hc|
  #      # Initialize the Highcharts default color array. Colors used in order and recycled => start off with H-Engage green
  #      # (Tried a whole bunch of ways to set these colors and this is the only way that worked. Beats me.)
  #      hc.colors
  #      hc.options[:colors][0] = '#4D7A36'
  #      hc.options[:colors][1] = '#F00'
  #
  #      hc.title(text: "H Engage #{name} Chart")
  #      hc.subtitle(text: "For #{start_date.to_s(:long)}")
  #
  #      hc.chart(zoomType: 'x')
  #
  #      hc.xAxis(title: {text: 'Date'}, type: 'datetime')
  #      hc.yAxis(title: {text: 'Acts'}, min: 0)
  #
  #      # Point interval is (number of seconds in) one day.
  #      # (LazyHighCharts gem converts to number of milliseconds, which Highcharts uses.)
  #      # todo if don't have option to display every other point => remove 'formatter' function
  #      hc.plotOptions(line: {pointStart: start_date.to_date, pointInterval: 60 * 60,
  #                            dataLabels: {enabled: true, fontWeight: 'bold', formatter: %|function() { return this.point.name; }|.js_code}})
  #
  #      hc.series(name: 'All Acts', data: all_hour_data)
  #      hc.series(name: 'Unique Acts', data: unique_hour_data)
  #    end
  #  end
  #end

  def highchart_daily(start_date, end_date)
    return nil if acts.count == 0  # todo need to gracefully handle this case

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
    date_range = Time.zone.local(start_date.year, start_date.month, start_date.day)..Time.zone.local(end_date.year, end_date.month, end_date.day)
    plot_acts = acts.where(created_at:(date_range))
    #plot_acts = acts.where(created_at:(date_range)).reject { |act| not date_range.include?(act.created_at.to_date) }

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
    # todo if don't have option to display every other point => just pass array of y values
    (all_data + unique_data).each_with_index { |point, i| i.even? ? point[0] = '' : point[0] = point[1].to_s }

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
      # todo if don't have option to display every other point => remove 'formatter' function
      hc.plotOptions(line: {pointStart: start_date.to_date, pointInterval: 60 * 60 * 24,
                            dataLabels: {enabled: true, fontWeight: 'bold', formatter: %|function() { return this.point.name; }|.js_code}})

      hc.series(name: 'All Acts', data: all_data)
      hc.series(name: 'Unique Acts', data: unique_data)
    end
  end

  #---------------------------------------------------------------------------------------

  # todo make these private

  # Since have to calculate all_acts in order to get unique_acts =>
  # Always calculate both instead of littering the code with a bunch of confusing conditionals
  def daily_acts(start_date, end_date, all_acts, unique_acts)
    all_acts_per_day = {}
    unique_acts_per_day = {}

    date_range = start_date..end_date
    date_range.each { |date| all_acts_per_day[date.to_date] = unique_acts_per_day[date.to_date] = 0 }

    num_all_acts_per_day = {}
    num_unique_acts_per_day = {}

    # Switch from DateTime to Time.zone.local because ActiveRecord's timestamps are UTC => for example, that an
    # act stored in the database at Dec. 25 at 2am would actually be an act for Dec. 24 at 9am because UTC is
    # 5 hours ahead of EST. Here is an example of how the 2 different times look:
    #   day = DateTime.new(2012, 12, 25)
    #   Tue, 25 Dec 2012 00:00:00 +0000
    #   Time.zone.local(day.year, day.month, day.day)
    #   Tue, 25 Dec 2012 00:00:00 EST -05:00
    date_range = Time.zone.local(start_date.year, start_date.month, start_date.day)..Time.zone.local(end_date.year, end_date.month, end_date.day)
    plot_acts = acts.where(created_at: date_range)

    raw_acts_per_day = plot_acts.group_by { |act| act.created_at.to_date }

    # todo rename k,v day, acts (or else comment what each is)
    raw_acts_per_day.each do |k,v|
      num_all_acts_per_day[k] = v.length

      # todo is this value correct? NOPE!  Needs to be by 'rule_id', but do after get basic structure in place so can test
      by_user = v.group_by &:user
      num_unique_acts_per_day[k] = by_user.keys.length
    end

    # 'merge' => any acts for a given day replace the initial '0' acts for that day, while
    #  keeping initial '0' for non-act days so have something to plot for each day.
    # 'sort' => by keys, i.e. creation date. Returns array of the form: [ [k,v], [k,v], [k,v], [k,v] ]
    all_data    = all_acts    ? all_acts_per_day.merge!(num_all_acts_per_day).sort       : []
    unique_data = unique_acts ? unique_acts_per_day.merge!(num_unique_acts_per_day).sort : []

    [all_data, unique_data]
  end

  def hourly_acts(date, all_acts, unique_acts)
    all_acts_per_hour = {}
    unique_acts_per_hour = {}

    start = date.beginning_of_day
    stop = date.end_of_day

    while stop > start
      all_acts_per_hour[start.hour] = unique_acts_per_hour[start.hour] = 0
      start += 1.hour
    end

    num_all_acts_per_hour = {}
    num_unique_acts_per_hour = {}

    hour_range = Time.zone.local(date.year, date.month, date.day).beginning_of_day..Time.zone.local(date.year, date.month, date.day).end_of_day
    plot_acts = acts.where(created_at: hour_range)

    raw_acts_per_hour = plot_acts.group_by { |act| act.created_at.hour }

    raw_acts_per_hour.each do |k,v|
      num_all_acts_per_hour[k] = v.length

      by_user = v.group_by &:user
      num_unique_acts_per_hour[k] = by_user.keys.length
    end

    all_data    = all_acts    ? all_acts_per_hour.merge!(num_all_acts_per_hour).sort       : []
    unique_data = unique_acts ? unique_acts_per_hour.merge!(num_unique_acts_per_hour).sort : []

    [all_data, unique_data]
  end

  def highchart(start_date, end_date = nil, all_acts, unique_acts)
    unless (start_date.instance_of?(DateTime) and (end_date.nil? or end_date.instance_of?(DateTime)))
      raise ArgumentError.new("Date argument(s) must be DateTime")
    end

    return "Nothing to plot" if ( ! (all_acts or unique_acts) or (acts.count == 0) )

    all_data, unique_data = end_date ? daily_acts(start_date, end_date, all_acts, unique_acts) :
                                       hourly_acts(start_date, all_acts, unique_acts)


    # Change the 'k' value (i.e. the date) for each [k,v] point to a string => Highcharts will not
    # use this value as the x-coordinate, but instead will treat it as the name of the point.
    # (Don't need it to be a true x/date value because we always plot one point per x-axis interval.)
    # todo if don't have option to display every other point => just pass array of y values
    (all_data + unique_data).each_with_index { |point, i| i.even? ? point[0] = '' : point[0] = point[1].to_s }

    LazyHighCharts::HighChart.new do |hc|
      # Initialize the Highcharts default color array. Colors used in order and recycled => start off with H-Engage green
      # (Tried a whole bunch of ways to set these colors and this is the only way that worked. Beats me.)
      hc.colors
      hc.options[:colors][0] = '#4D7A36'
      hc.options[:colors][1] = '#F00'

      hc.title(text: "H Engage #{name} Chart")

      subtitle = end_date ? "#{start_date.to_s(:long)} thru #{end_date.to_s(:long)}" : "#{start_date.to_s(:long)}"
      hc.subtitle(text: subtitle)

      hc.chart(zoomType: 'x')  # todo take this out

      xAxis = end_date ? 'Date' : 'Hour'
      hc.xAxis(title: {text: xAxis}, type: 'datetime')
      hc.yAxis(title: {text: 'Acts'}, min: 0)

      # Point interval is (number of seconds in) one day.
      # (LazyHighCharts gem converts to number of milliseconds, which Highcharts uses.)
      # todo if don't have option to display every other point => remove 'formatter' function
      pointInterval = end_date ? 60 * 60 * 24 : 60 * 60
      hc.plotOptions(line: {pointStart: start_date.to_date, pointInterval: pointInterval,
                            dataLabels: {enabled: true, fontWeight: 'bold', formatter: %|function() { return this.point.name; }|.js_code}})

      hc.series(name: 'All Acts',    data: all_data)    if all_acts
      hc.series(name: 'Unique Acts', data: unique_data) if unique_acts
    end
  end
  #---------------------------------------------------------------------------------------

  def highchart_hourly(start_date)
    # todo need to handle this case
    return nil if acts.count == 0

    all_acts_per_hour = {}
    unique_acts_per_hour = {}

    start = start_date.beginning_of_day
    stop = start_date.end_of_day

    while stop > start
      all_acts_per_hour[start.hour] = unique_acts_per_hour[start.hour] = 0
      start += 1.hour
    end

    num_all_acts_per_hour = {}
    num_unique_acts_per_hour = {}

    # todo embellish this comment
    # AR dates are UTC time. Need to reject dbase entries like this "created_at: 2012-12-10 02:37:36" because
    # if you do an 'act.created_at' for that time you get "Sun, 09 Dec 2012 21:37:36 EST -05:00", which would
    # not fall in the 10..20 range. Note that the class of 'act.created_at' is actually 'ActiveSupport::TimeWithZone'
    # thus you need to convert it if you want to test range inclusion.
    # Here's the fucked-up thing: range is expressed in DateTime's, but if you do an 'act.created_at.to_datetime'
    # then *nothing* gets rejected.
    hour_range = Time.zone.local(start_date.year, start_date.month, start_date.day).beginning_of_day..Time.zone.local(start_date.year, start_date.month, start_date.day).end_of_day
    hour_acts = acts.where(created_at:(hour_range))

    raw_acts_per_hour = hour_acts.group_by { |act| act.created_at.hour }

    raw_acts_per_hour.each do |k,v|
      num_all_acts_per_hour[k] = v.length

      by_user = v.group_by &:user
      num_unique_acts_per_hour[k] = by_user.keys.length
    end

    # 'merge' => any acts for a given day replace the initial '0' acts for that day, while
    #  keeping initial '0' for non-act days so have something to plot for each day.
    # 'sort' => by keys, i.e. creation date. Returns array of the form: [ [k,v], [k,v], [k,v], [k,v] ]
    all_hour_data = all_acts_per_hour.merge!(num_all_acts_per_hour).sort
    unique_hour_data = unique_acts_per_hour.merge!(num_unique_acts_per_hour).sort

    # Change the 'k' value (i.e. the date) for each [k,v] point to a string => Highcharts will not
    # use this value as the x-coordinate, but instead will treat it as the name of the point.
    # (Don't need it to be a true x/date value because we always plot one point per x-axis interval.)
    # todo if don't have option to display every other point => just pass array of y values
    (all_hour_data + unique_hour_data).each_with_index { |point, i| i.even? ? point[0] = '' : point[0] = point[1].to_s }

    LazyHighCharts::HighChart.new do |hc|
      # Initialize the Highcharts default color array. Colors used in order and recycled => start off with H-Engage green
      # (Tried a whole bunch of ways to set these colors and this is the only way that worked. Beats me.)
      hc.colors
      hc.options[:colors][0] = '#4D7A36'
      hc.options[:colors][1] = '#F00'

      hc.title(text: "H Engage #{name} Chart")
      hc.subtitle(text: "#{start_date.to_s(:long)}")

      hc.chart(zoomType: 'x')

      hc.xAxis(title: {text: 'Date'}, type: 'datetime')
      hc.yAxis(title: {text: 'Acts'}, min: 0)

      # Point interval is (number of seconds in) one day.
      # (LazyHighCharts gem converts to number of milliseconds, which Highcharts uses.)
      # todo if don't have option to display every other point => remove 'formatter' function
      hc.plotOptions(line: {pointStart: start_date.to_date, pointInterval: 60 * 60,
                            dataLabels: {enabled: true, fontWeight: 'bold', formatter: %|function() { return this.point.name; }|.js_code}})

      hc.series(name: 'All Acts', data: all_hour_data)
      hc.series(name: 'Unique Acts', data: unique_hour_data)
    end
  end
end