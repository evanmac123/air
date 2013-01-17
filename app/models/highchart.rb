class Highchart

=begin
  Regarding the LazyHighCharts gem
  ================================

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

  Regarding the Highcharts API
  ============================

  What you plot is a 'series', which you specify various options for, e.g. 'name' and 'data'.

  You can include any of the appropriate 'plotOptions' as part of the 'series' params.
  Instead of duplicating parameters for 'acts' and 'users' (and future) graphs, specify same-value
  params as part of the 'plotOptions'.

  Zooming is disabled because (a) the K's never used it and (b) if allowed => should keep the begin- and end-date
  controls in synch with it, which would be a pain.
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
=end

  def self.chart(type, demo, start_date, end_date, acts, users)
    # todo beef up and handle in the controller (flash?) and/or view
    return "Nothing to plot" if ( ! (acts or users) or (demo.acts.count == 0) )

    chart = case type
              when :hour then Hourly.new(demo, start_date, end_date, acts, users)
              when :day  then Daily.new(demo, start_date, end_date, acts, users)
              when :week then Weekly.new(demo, start_date, end_date, acts, users)
            end

    act_points, user_points = chart.data_points

    (act_points + user_points).each_with_index { |point, i| i.even? ? point[0] = '' : point[0] = point[1].to_s }

    LazyHighCharts::HighChart.new do |hc|
      # Tried a bunch of ways to set these colors and this is the only way that worked. Beats me...
      hc.colors
      hc.options[:colors][0] = '#4D7A36'
      hc.options[:colors][1] = '#F00'

      # Keep the 'Save As Image/PDF' button but get rid of the 'Print' one
      hc.exporting(buttons: {printButton: {enabled: false}})

      hc.title(text: "H Engage #{demo.name} Chart")
      hc.subtitle(text: chart.subtitle)

      hc.xAxis(title: {text: nil}, type: 'datetime')
      hc.yAxis(title: {text: nil}, min: 0)  # todo min not 0 ; might be chart-dependent

      hc.plotOptions(line: {pointStart: start_date.to_date,
                            pointInterval: chart.point_interval,
                            dataLabels: {enabled: true,
                                         fontWeight: 'bold',
                                         formatter: "function() { return this.point.name; }".js_code}})

      hc.series(name: 'Acts',  data: act_points)  if acts
      hc.series(name: 'Users', data: user_points) if users
    end
  end

  #--------------------------- Helper Classes ----------------------------

  # Someone else said it better than I could (which still doesn't make this "the best way"):
  #   Generally I think using nested classes for real helper classes that can conceptually
  #   only be used with the parent class is a useful way of avoiding namespace clutter.

  private

  #--------------------------- Generic Parent Class ----------------------------
  class Chart
    def initialize(demo, start_date, end_date, acts, users)
      @demo = demo

      @start_date = start_date
      @end_date = end_date

      @acts = acts
      @users = users

      @acts_per_interval  = {}
      @users_per_interval = {}

      @num_acts_per_interval  = {}
      @num_users_per_interval = {}
    end

    def get_plot_acts(range)
      @demo.acts.where(created_at: range)
    end

    def calculate_number_per_interval(acts_per_interval)
      acts_per_interval.each do |k,v|
        @num_acts_per_interval[k] = v.length

        by_user = v.group_by &:user
        @num_users_per_interval[k] = by_user.keys.length
      end
    end

    def data_points
      # Merge initialized-to-zero hash elements with elements that have values =>
      # will always have (zero or non-zero) value to plot for each point.
      #
      # 'sort' sorts by keys (i.e. creation date/time) and returns an array of the form: [ [k,v], [k,v], [k,v], [k,v] ]
      act_data  = @acts  ? @acts_per_interval.merge!(@num_acts_per_interval).sort   : []
      user_data = @users ? @users_per_interval.merge!(@num_users_per_interval).sort : []

      [act_data, user_data]
    end
  end

  #--------------------------- Chart-Specific Child Class ----------------------------
  class Hourly < Chart
    def subtitle
      "#{@start_date.to_s(:long)}"
    end

    def point_interval
      60 * 60
    end

    def data_points
      # Initialize acts and users to 0 for plotting interval
      start = @start_date.beginning_of_day
      stop  = @start_date.end_of_day
      while stop > start
        @acts_per_interval[start.hour] = @users_per_interval[start.hour] = 0
        start += 1.hour
      end

      # Perform query using Time.zone.local because AR's timestamps are UTC => 5 hours ahead of EST
      range = Time.zone.local(@start_date.year, @start_date.month, @start_date.day).beginning_of_day..
              Time.zone.local(@start_date.year, @start_date.month, @start_date.day).end_of_day
      plot_acts = get_plot_acts(range)

      # Group all of the acts by hour and use to calculate the raw number of acts/users for each hour
      acts_per_interval = plot_acts.group_by { |act| act.created_at.hour }
      calculate_number_per_interval(acts_per_interval)

      super  # Performed class-specific calculations => Let base class finish up and return the data
    end
  end

  #--------------------------- Chart-Specific Child Class ----------------------------
  class Daily < Chart
    def subtitle
      "#{@start_date.to_s(:long)} thru #{@end_date.to_s(:long)}"
    end

    def point_interval
      60 * 60 * 24
    end

    def data_points
      # Initialize acts and users to 0 for plotting interval
      range = @start_date..@end_date
      range.each { |date| @acts_per_interval[date.to_date] = @users_per_interval[date.to_date] = 0 }

      # Perform query using Time.zone.local because AR's timestamps are UTC => 5 hours ahead of EST
      range = Time.zone.local(@start_date.year, @start_date.month, @start_date.day)..
              Time.zone.local(@end_date.year, @end_date.month, @end_date.day)
      plot_acts = get_plot_acts(range)

      # Group all of the acts by day and use to calculate the raw number of acts/users for each day
      acts_per_interval = plot_acts.group_by { |act| act.created_at.to_date }
      calculate_number_per_interval(acts_per_interval)

      super  # Performed class-specific calculations => Let base class finish up and return the data
    end
  end

  #--------------------------- Chart-Specific Child Class ----------------------------
  class Weekly < Chart
    def subtitle
      "#{@start_date.to_s(:long)} thru #{@end_date.to_s(:long)} BY WEEK"
    end

    def point_interval
      60 * 60 * 24 * 7
    end

    def data_points
      # Initialize acts and users to 0 for plotting interval
      range = @start_date..@end_date
      range.step(7) { |date| @acts_per_interval[date.to_date] = @users_per_interval[date.to_date] = 0 }

      # Perform query using Time.zone.local because AR's timestamps are UTC => 5 hours ahead of EST
      range = Time.zone.local(@start_date.year, @start_date.month, @start_date.day)..
              Time.zone.local(@end_date.year, @end_date.month, @end_date.day)
      plot_acts = get_plot_acts(range)

      # Each 'week point' will contain all acts/users from that day up to, but not including, the next day in the range.
      # (Which means the last 'week point' will contain all acts/users from that day up to the end of the range)
      acts_per_interval = {}
      (@start_date..@end_date).step(7) do |date|
        partition = plot_acts.partition { |act| act.created_at.to_date < date + 7.days }
        acts_per_interval[date] = partition[0]
        plot_acts = partition[1]
      end
      calculate_number_per_interval(acts_per_interval)

      super  # Performed class-specific calculations => Let base class finish up and return the data
    end
  end
end