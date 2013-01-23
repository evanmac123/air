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

  Regardless, if you want to do it that way you need to do is this for the second statement:
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
  (in /vendor/assets/javascripts/admin) and adding both to /app/assets/javascripts/app-admin.js
=end

  # Converts a (form-input) "month/day/year" string into a "day/month/year" (datetime-expected) string,
  # e.g. '7/21/2013' to '21/7/2013', and then converts that string to a DateTime object.
  def self.convert_date(date_string)
    date_string.sub(/(\d{1,2})\/(\d{1,2})\/(\d{1,4})/, '\2/\1/\3').to_datetime
  end

  def self.chart(demo, interval, start_date, end_date, plot_acts, plot_users, label_points)
    # 'chart' will be a new 'Hourly', 'Daily', or 'Weekly' object (defined below)
    chart = "Highchart::#{interval}".constantize.new(demo, start_date, end_date, plot_acts, plot_users)

    act_points, user_points = chart.data_points

    # Currently have an option to label all, none, or every other point.
    # If we do attach a label, make it just the value for that point (i.e. without the date)
    # todo this will change with Connie's new UI
    (act_points + user_points).each_with_index do |point, i|
      point[0] = (i % label_points.to_i == 0) ? point[1].to_s : ''
    end unless label_points == '0'

    LazyHighCharts::HighChart.new do |hc|
      # Tried a bunch of ways to set these colors and this is the only way that worked. Beats me...
      hc.colors
      hc.options[:colors][0] = '#4D7A36'
      hc.options[:colors][1] = '#F00'

      # Remove the 'Print' button (but keep the 'Save As Image/PDF' one)
      hc.exporting(buttons: {printButton: {enabled: false}})

      hc.title(text: "H Engage #{demo.name} Chart")
      hc.subtitle(text: chart.subtitle)

      # Bump up the 'maxPadding' a little because the right-hand edge of last date was getting chopped
      hc.xAxis(title: {text: nil}, type: 'datetime', maxPadding: 0.02, labels: {formatter: chart.x_axis_label.js_code})
      hc.yAxis(title: {text: nil}, min: 0)

      # Defining a javascript function for the formatter is what allows us to label every n points
      # See the Highcharts API for 'dataLabels:formatter' and the LazyHighcharts GitHub page for '~~~.js_code'
      hc.plotOptions(line: {pointStart:    Highchart.convert_date(start_date).to_date,
                            pointInterval: chart.point_interval,
                            dataLabels:    {enabled:    label_points != '0',
                                            fontWeight: 'bold',
                                            formatter:  "function() { return this.point.name; }".js_code}})

      hc.series(name: 'Acts',  data: act_points)  if plot_acts
      hc.series(name: 'Users', data: user_points) if plot_users
    end
  end

  #================================== Helper Classes =======================================

  # Someone else said it better than I could:
  #   Generally I think using nested classes for real helper classes that can conceptually
  #   only be used with the parent class is a useful way of avoiding namespace clutter.

  #--------------------------- Generic Parent Class ----------------------------
  class Chart
    def initialize(demo, start_date, end_date, plot_acts, plot_users)
      @demo = demo

      @start_date = Highchart.convert_date(start_date).beginning_of_day  # Starts at 12:00:00 am
      @end_date   = Highchart.convert_date(end_date).end_of_day          # Ends at 11:59:59 pm

      @plot_acts  = plot_acts
      @plot_users = plot_users

      @acts_per_interval  = {}
      @users_per_interval = {}

      @num_acts_per_interval  = {}
      @num_users_per_interval = {}
    end

    def data_points
      initialize_all_data_points_to_zero   # child-class specific

      all_acts = get_all_acts_between_start_and_end_dates

      acts_per_interval = group_acts_per_time_interval(all_acts)  # child-class specific

      calculate_number_per_time_interval(acts_per_interval)

      prepare_and_return_results
    end

    def get_all_acts_between_start_and_end_dates
      range = @start_date..@end_date
      @demo.acts.where(created_at: range)
    end

    # 'acts_per_interval' is a hash containing many entries of the form { time-interval-point => [ acts for that point ] }
    def calculate_number_per_time_interval(acts_per_interval)
      acts_per_interval.each do |interval, acts|
        @num_acts_per_interval[interval] = acts.length

        by_user = acts.group_by &:user_id
        @num_users_per_interval[interval] = by_user.keys.length
      end
    end

    def prepare_and_return_results
      # Merge initialized-to-zero hash elements with elements that have values =>
      # will always have (zero or non-zero) value to plot for each point.
      #
      # 'sort' sorts the hash by keys (i.e. creation date/time) and returns an array of the form: [ [k,v], [k,v], [k,v] ]
      # where the key is the date/time x-axis point and the value is the number of acts/users y-axis value for that point
      act_data  = @plot_acts  ? @acts_per_interval.merge!(@num_acts_per_interval).sort   : []
      user_data = @plot_users ? @users_per_interval.merge!(@num_users_per_interval).sort : []

      [act_data, user_data]
    end
  end

  #--------------------------- Chart-Specific Child Class ----------------------------
  class Hourly < Chart
    def subtitle
      "#{@start_date.to_s(:chart_subtitle_one_day)} : By Hour"
    end

    def x_axis_label
      "function() { return Highcharts.dateFormat('%l %p', this.value); }"
    end

    def point_interval
      60 * 60
    end

    def initialize_all_data_points_to_zero
      start = @start_date
      stop  = @end_date

      while stop > start
        @acts_per_interval[start.hour] = @users_per_interval[start.hour] = 0
        start += 1.hour
      end
    end

    # Need to adjust the key for the grouping to fit into a 0 - 23 (hour) range.
    # Why? Best to show by sample output from the following 'p' statement for all acts that were created on Dec. 25, 2012:
    # Note that single-digit keys correspond to acts with the 'day' actually Dec. 24 in the database due to EST/UTC mismatch.
    #
    # p "created_at is #{act.created_at} and hour is #{act.created_at.hour} and adjusted hour is #{(act.created_at.hour + 5) % 24}"
    #
    #"created_at is 2012-12-24 19:01:00 -0500 and hour is 19 and adjusted hour is 0"
    #"created_at is 2012-12-25 18:58:59 -0500 and hour is 18 and adjusted hour is 23"
    #"created_at is 2012-12-24 20:00:00 -0500 and hour is 20 and adjusted hour is 1"
    #"created_at is 2012-12-25 17:59:59 -0500 and hour is 17 and adjusted hour is 22"
    #"created_at is 2012-12-24 19:02:00 -0500 and hour is 19 and adjusted hour is 0"
    #"created_at is 2012-12-25 18:57:59 -0500 and hour is 18 and adjusted hour is 23"
    #"created_at is 2012-12-24 21:00:00 -0500 and hour is 21 and adjusted hour is 2"
    #"created_at is 2012-12-25 16:59:59 -0500 and hour is 16 and adjusted hour is 21"
    def group_acts_per_time_interval(acts)
      acts.group_by { |act| (act.created_at.hour + 5) % 24 }
    end
  end

  #--------------------------- Chart-Specific Child Class ----------------------------
  class Daily < Chart
    def subtitle
      "#{@start_date.to_s(:chart_subtitle_range)} through #{@end_date.to_s(:chart_subtitle_range)} : By Day"
    end

    def x_axis_label
      "function() { return Highcharts.dateFormat('%b. %d', this.value); }"
    end

    def point_interval
      60 * 60 * 24
    end

    def initialize_all_data_points_to_zero
      range = @start_date..@end_date
      range.each { |date| @acts_per_interval[date.to_date] = @users_per_interval[date.to_date] = 0 }
    end

    # todo 5 needs to be a variable FUCK
    def group_acts_per_time_interval(acts)
      # Need to add in the EST/UTC difference in order to get correct grouping
      acts.group_by { |act| (act.created_at + 5.hours).to_date }
    end
 end

  #--------------------------- Chart-Specific Child Class ----------------------------
  class Weekly < Chart
    def subtitle
      "#{@start_date.to_s(:chart_subtitle_range)} through #{@end_date.to_s(:chart_subtitle_range)} : By Week"
    end

    def x_axis_label
      "function() { return Highcharts.dateFormat('%b. %d', this.value); }"
    end

    def point_interval
      60 * 60 * 24 * 7
    end

    def initialize_all_data_points_to_zero
      range = @start_date..@end_date
      range.step(7) { |date| @acts_per_interval[date.to_date] = @users_per_interval[date.to_date] = 0 }
    end

    def group_acts_per_time_interval(acts)
      # Each 'week point' will contain all acts from that day up to, but not including, the next day in the range.
      # (Which means the last 'week point' will contain all acts from the last day up to the end of the range)
      acts_per_interval = {}

      (@start_date..@end_date).step(7) do |date|
        # Need to add in the EST/UTC difference in order to get correct grouping
        partition = acts.partition { |act| (act.created_at + 5.hours).to_date < date + 7.days }

        unless partition[0].empty?  # Only create a date pointing to an array of acts if there's an array of acts
          acts_per_interval[date] = partition[0]
          acts = partition[1]
        end
      end

      acts_per_interval
    end
  end
end