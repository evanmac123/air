class Highchart

=begin
  LazyHighCharts gem
  ==================

  This gem is an RoR front-end to the Highcharts API

  It's arguably clearer (albeit more wordy) to specify options using specific selectors, e.g.
    hc.options[:xAxis][:categories] = [3, 5, 7]
    hc.options[:xAxis][:title][:text] = 'x title'
  because it makes it easier to correlate what you see in the code with the Highchart api docs.

  The first statement above works, but the second one results in a "calling []= on nil" error.
  There is a bug description on this at: https://github.com/michelson/lazy_high_charts/pull/77
  The doc implies that subsequent releases incorporated a bug fix, but that doesn't seem to be the case.

  Regardless, if you want to do it that way you need to do this for the second statement:
    hc.options[:xAxis][:title] = {}
    hc.options[:xAxis][:title][:text] = 'x title'

  Highcharts API
  ==============

  What you plot is a 'series', for which you specify various options, e.g. 'name' and 'data'.

  You can include any of the appropriate 'plotOptions' options as part of the 'series' params.
  Instead of duplicating parameters for 'acts' and 'users' (and future) graphs we specify same-value
  params as part of the 'plotOptions'.

  Zooming is disabled because (a) the K's never used it and (b) if allowed => should keep the
  begin- and end-date controls in synch with it, which would be a pain.
    * To enable zooming: hc.chart(zoomType: 'x')

  To change the labels on the X-axis:
    hc.xAxis(dateTimeLabelFormats: {day: 'This be the day: %e', week: 'This be the month: %b'})
    * Note that milliseconds are also rendered by default for datetimes. (The site's doc doesn't mention this and it makes
      you think you're doing something wrong with the labels if you're not aware of it.) (Guess what I wasted time on.)
    * The site lists the default formats, however, it doesn't list the time/date patterns you can use. Here they are:
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

  Saving and printing the chart is accomplished by including 'exporting.js' along with 'highcharts.js'
  (in /vendor/assets/javascripts/client_admin) and adding both to /app/assets/javascripts/app-client-admin.js
=end

  # Converts a (form-input) "month/day/year" string into a "day/month/year" (datetime-expected) string,
  # e.g. '7/21/2013' to '21/7/2013', and then converts that string to a DateTime object.
  def self.convert_date(date_string)
    date_string.sub(/(\d{1,2})\/(\d{1,2})\/(\d{1,4})/, '\2/\1/\3').to_datetime
  end

  def self.chart(demo, start_date, end_date, plot_content, interval, label_points)
    plot_acts  = true if plot_content == 'Total activity' or plot_content == 'Both'
    plot_users = true if plot_content == 'Unique users'   or plot_content == 'Both'

    # 'chart' will be a new 'Hourly', 'Daily', or 'Weekly' object (defined below)
    chart = "Highchart::#{interval}".constantize.new(demo, start_date, end_date, plot_acts, plot_users)

    act_points, user_points = chart.data_points  # Get the points to plot

    # Figure out the labeling. Remember that 'act_points' and 'user_points' are arrays of the form: [ [k,v], [k,v], [k,v] ]
    # where the key is the date/time x-axis point and the value is the number of acts/users y-axis value for that point
    data_labels = { enabled: true, formatter: "function() { return this.y; }".js_code }

    if label_points == '1'
      act_points = act_points.collect   { |act|  {y: act.second,  dataLabels: data_labels} }
      user_points = user_points.collect { |user| {y: user.second, dataLabels: data_labels} }
    elsif label_points == '2'
      act_points = act_points.each_with_index.collect   { |act, i|  i.even? ? {y: act.second,  dataLabels: data_labels} : act.second }
      user_points = user_points.each_with_index.collect { |user, i| i.even? ? {y: user.second, dataLabels: data_labels} : user.second }
    else
      act_points = act_points.collect   &:second
      user_points = user_points.collect &:second
    end

    LazyHighCharts::HighChart.new do |hc|
      hc.exporting(buttons: {printButton: {enabled: false}})  # Remove 'Print' button ; keep 'Save As Image/PDF'

      hc.title(text: "Activity Levels", style: {color: '#4c4c4c', 
        "font-size" => "16px", "font-family" => "Helvetica Neue", 
        "font-style" => "normal", "font-weight" => "bold", "font-weight" => "500"})
      hc.subtitle(text: chart.subtitle, style: {color: '#a8a8a8',
        "font-size" => "14px", "font-family" => "Helvetica Neue", 
        "font-style" => "normal", "font-weight" => "normal", "font-weight" => "400"})

      hc.legend(layout: 'horizontal')

      # Bump 'maxPadding' because the right-hand edge of last date was getting chopped
      hc.xAxis(title: {text: nil}, type: 'datetime', maxPadding: 0.02, labels: {formatter: chart.x_axis_label.js_code})
      hc.yAxis(title: {text: nil}, min: 0, gridLineColor: '#DED7D7')

      hc.plotOptions(line: {pointStart: Highchart.convert_date(start_date).to_date, pointInterval: chart.point_interval})

      # In Hourly Mode (and only Hourly Mode) the tooltips report the time in military time, e.g. for 3am they say
      # '03:00', but for 3pm they say '15:00'. Asked a question on StackOverflow:
      # http://stackoverflow.com/questions/14718828/formatting-highcharts-date-in-tooltip-causes-values-to-change
      # but still couldn't get the &%$#@! thing to work.
      # The problem is that when you use either of the attempts below, all of the times on the x-axis say '12am'
      # and the tooltip times are in %$#@! milliseconds!
      # Spent too much time on this and have other stuff to do. If it becomes necessary to solve this the commented-out
      # code is a good starting point as you will know what *won't* work.
      #
      #hc.plotOptions(tooltip: {xDateFormat: '%A, %b %e, %l %p' }) if interval == 'Hourly'
      #hc.plotOptions(tooltip: {formatter: "function() { return Highcharts.dateFormat('%A, %b %e, %l %p', this.value); }".js_code }) if interval == 'Hourly'

      hc.series(name: 'Acts',  data: act_points,  color: '#4FAA60') if plot_acts
      hc.series(name: 'Users', data: user_points, color: '#4face0') if plot_users
    end
  end

  #================================== Helper Classes =======================================

  #--------------------------- Generic Parent Class ----------------------------

  class Chart

    attr_reader(:num_acts_per_interval, :num_users_per_interval) if Rails.env.test?  # Only needed for testing

    def initialize(demo, start_date, end_date, plot_acts, plot_users)
      @demo = demo

      @start_date = Highchart.convert_date(start_date).beginning_of_day  # Start at 12:00:00 am
      @end_date   = Highchart.convert_date(end_date).end_of_day          # End at 11:59:59 pm

      @plot_acts  = plot_acts
      @plot_users = plot_users

      @acts_per_interval  = {}
      @users_per_interval = {}
    end

    def data_points
      acts_per_interval  = {}
      users_per_interval = {}

      initialize_all_data_points_to_zero   # child-class implementation

      # This query groups all acts within the specified dates by the appropriate time interval (i.e. day, hour, week)
      # and then groups the acts within each of those groups by the user_id.
      # It then orders those results by the time interval and counts the number of elements within each group.
      #
      # So what we have at this point would look something like this (for hourly mode):
      # [[[2013-01-30 00:00:00, 43], 1], [[2013-01-30 00:00:00, 54], 3], [[2013-01-30 01:00:00, 62], 2], [[2013-01-30 03:00:00, 33], 4]]
      # Which is interpreted thusly: An array where each element consists of a hash and an integer.
      # The (element-1) hash has a key of time-interval and a value of the user_id for this "group"
      # The (element-2) integer is the number of acts that that user completed during that time interval.
      # So in the example above, at hour-0 user-43 did 1 act, at hour-0 user-54 did 3 acts, at hour-1 user-62 did 2 acts, at hour-3 user-33 did 4 acts
      #
      # Still with me? Good!
      #
      # We then want to group all of those elements by time interval. To do so we grab the first element, which is a hash
      # whose key is a 2-element array of the time-interval that we want coupled with a user_id => take the [0]th element of that key.
      #
      # Which finally results in something (hash, actually) like this:
      # { 2013-01-30 00:00:00 => [[[2013-01-30 00:00:00, 43], 1], [[2013-01-30 00:00:00, 54], 3]],
      #   2013-01-30 01:00:00 => [[[2013-01-30 01:00:00, 62], 2]],
      #   2013-01-30 03:00:00 => [[[2013-01-30 03:00:00, 33], 4]] }
      #
      # So the result contains all of the information we need broken down by time-interval to plot => the only thing
      # we need to do in Ruby code is calculate the number-of-acts and number-of-users for each interval, which is
      # done in the code block below the query.
      #
      # The number-of-users for each time interval is just the number of entries for that interval, as each entry is for a
      # specific user.
      # For the number-of-acts we have to cycle through each entry and total up the number of acts that each of the users did.
      #
      # When we're done with that we need to remember that we only have values for time-intervals where acts occurred.
      # But we have to plot all points - including those with '0' acts => merge with previously initialized 0-value hash.
      #
      # Still with me? No you're not. Not even I am, so quit fucking lying!!!
      #
      grouped_acts = @demo.acts.select("date_trunc('#{time_unit}', created_at), user_id")
                               .where(created_at: @start_date..@end_date)
                               .group("date_trunc('#{time_unit}', created_at)")
                               .group('user_id')
                               .order("date_trunc('#{time_unit}', created_at)")
                               .count
                               .group_by { |k,v| k[0] }

      grouped_acts.each do |time, act_group|
        acts_per_interval[time_key(time)]  = act_group.inject(0) { |sum, acts_for_user| sum + acts_for_user[1] }
        users_per_interval[time_key(time)] = act_group.length
      end

      # Merge initialized-to-zero hash elements with elements that have values =>
      # will always have (zero or non-zero) value to plot for each point.
      act_data  = @plot_acts  ? @acts_per_interval.merge!(acts_per_interval)   : []
      user_data = @plot_users ? @users_per_interval.merge!(users_per_interval) : []

      [act_data, user_data]
    end
  end

  #--------------------------- Chart-Specific Child Class ----------------------------

  class Hourly < Chart
    def subtitle
      "#{@start_date.to_s(:chart_subtitle_one_day)} - By Hour"
    end

    def x_axis_label
      "function() { return Highcharts.dateFormat('%l %p', this.value); }"
    end

    def time_unit
      'hour'
    end

    def time_key(time)
      time.to_time.localtime.hour
    end

    def point_interval
      60 * 60
    end

    def initialize_all_data_points_to_zero
      start = @start_date
      stop  = @end_date

      # Result looks like: {0 => 0, 1 => 0, 2 => 0, 3 => 0, ... 11 => 0, 12 => 0, 13 => 0, ... 21 => 0, 22 => 0, 23 => 0}
      while stop > start
        @acts_per_interval[start.hour] = @users_per_interval[start.hour] = 0
        start += 1.hour
      end
    end
  end

  #--------------------------- Chart-Specific Child Class ----------------------------

  class Daily < Chart
    def subtitle
      "#{@start_date.to_s(:chart_subtitle_range)} through #{@end_date.to_s(:chart_subtitle_range)} - By Day"
    end

    def x_axis_label
      "function() { return Highcharts.dateFormat('%b. %d', this.value); }"
    end

    def time_unit
      'day'
    end

    def time_key(time)
      time.to_date
    end

    def point_interval
      60 * 60 * 24
    end

    # Result looks like: {Wed, 30 Jan 2013 => 0, Thu, 31 Jan 2013 => 0, Fri, 01 Feb 2013 => 0, Sat, 02 Feb 2013 => 0, ...}
    def initialize_all_data_points_to_zero
      range = @start_date..@end_date
      range.each { |date| @acts_per_interval[date.to_date] = @users_per_interval[date.to_date] = 0 }
    end
  end

  #--------------------------- Chart-Specific Child Class ----------------------------

  class Weekly < Chart
    def subtitle
      "#{@start_date.to_s(:chart_subtitle_range)} through #{@end_date.to_s(:chart_subtitle_range)} - By Week"
    end

    def x_axis_label
      "function() { return Highcharts.dateFormat('%b. %d', this.value); }"
    end

    def time_unit
      'week'
    end

    def time_key(time)
      time.to_date
    end

    def point_interval
      60 * 60 * 24 * 7
    end

    # Result looks like: {Mon, 28 Jan 2013 => 0, Mon, 04 Feb 2013 => 0, Mon, 11 Feb 2013 => 0, Mon, 18 Feb 2013 => 0, ...}
    def initialize_all_data_points_to_zero
      # When Postgresql groups by week, it does so using a "weeks begin on Monday" rule.
      # This is intuitively good for Tues..Sat, as the @start_date is just backed up to the preceding Monday - in the same week.
      # But it's counter-intuitive for Sundays: the @start_date is still backed up to the preceding Monday,
      # which happens to be in the *previous* week. (Not bad or an error, just something to be aware of.)
      @start_date = @start_date.beginning_of_week

      range = @start_date..@end_date
      range.step(7) { |date| @acts_per_interval[date.to_date] = @users_per_interval[date.to_date] = 0 }
    end
  end
end