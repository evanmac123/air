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

  You can also include any of the appropriate 'plotOptions' as part of the 'series' params.
  Instead of duplicating parameters for 'acts' and 'users' (and future) graphs, we specify same-value
  params as part of the 'plotOptions' and then override them (if need be) in the individual 'series' params.

  Zooming is disabled because ()a) the K's never used it and (b) if allowed => should keep the begin- and end-date
  controls in synch with it, which would be a pain.
    * To enable zooming: hc.chart(zoomType: 'x')

  To change the labels on the X-axis:
    hc.xAxis(dateTimeLabelFormats: {day: 'This be the day: %e', week: 'This be the month: %b'})
  Note that milliseconds are also rendered by default for datetimes. (The site's doc doesn't mention this and it makes
  you think you're doing something wrong with the labels if you're not aware of it.) (Guess what I wasted time on.)
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

  def self.chart(type, demo, start_date, end_date, acts, users)
    # todo beef up and handle in the controller (flash?) and/or view
    return "Nothing to plot" if ( ! (acts or users) or (demo.acts.count == 0) )

    chart = case type
              when :hour then self::Hourly.new(demo, start_date, end_date, acts, users)
              when :day  then self::Daily.new(demo, start_date, end_date, acts, users)
              when :week then self::Weekly.new(demo, start_date, end_date, acts, users)
            end

    act_points, user_points = chart.data_points

    (act_points + user_points).each_with_index { |point, i| i.even? ? point[0] = '' : point[0] = point[1].to_s }

    LazyHighCharts::HighChart.new do |hc|
      # Tried a bunch of ways to set these colors and this is the only way that worked. Beats me...
      hc.colors
      hc.options[:colors][0] = '#4D7A36'
      hc.options[:colors][1] = '#F00'

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

  # Someone else said it better than I could (which still doesn't make this the "best way"):
  # Generally I think using nested classes for real helper classes that can conceptually
  # only be used with the parent class is a useful way of avoiding namespace clutter.

  private

  class Hourly
    def initialize(demo, start_date, end_date, acts, users)
      @demo = demo
      @start_date = start_date
      @end_date = end_date
      @acts = acts
      @users = users
    end

    def subtitle
      "#{@start_date.to_s(:long)}"
    end

    def point_interval
      60 * 60
    end

    def data_points
      acts_per_hour = {}
      users_per_hour = {}

      start = @start_date.beginning_of_day
      stop = @start_date.end_of_day

      while stop > start
        acts_per_hour[start.hour] = users_per_hour[start.hour] = 0
        start += 1.hour
      end

      num_acts_per_hour = {}
      num_users_per_hour = {}

      # todo move comments to daily

      # Switch range from DateTime to Time.zone.local because ActiveRecord's timestamps are UTC => for example, that an
      # act stored in the database at Dec. 25 at 2am would actually be an act for Dec. 24 at 9am because UTC is
      # 5 hours ahead of EST. Here is an example of how the 2 different times look (Rails console output):
      #   day = DateTime.new(2012, 12, 25)
      #   Tue, 25 Dec 2012 00:00:00 +0000
      #   Time.zone.local(day.year, day.month, day.day)
      #   Tue, 25 Dec 2012 00:00:00 EST -05:00
      hour_range = Time.zone.local(@start_date.year, @start_date.month, @start_date.day).beginning_of_day..Time.zone.local(@start_date.year, @start_date.month, @start_date.day).end_of_day
      plot_acts = @demo.acts.where(created_at: hour_range)

      raw_acts_per_hour = plot_acts.group_by { |act| act.created_at.hour }

      # todo rename k,v day, acts (or else comment what each is)
      raw_acts_per_hour.each do |k,v|
        num_acts_per_hour[k] = v.length

        # todo maybe wrap this in an "if users" stmt.
        by_user = v.group_by &:user
        num_users_per_hour[k] = by_user.keys.length
      end

      # 'merge' => any acts for a given day replace the initial '0' acts for that day, while
      #  keeping initial '0' for non-act days so have something to plot for each day.
      # 'sort' => by keys, i.e. creation date. Returns array of the form: [ [k,v], [k,v], [k,v], [k,v] ]
      act_data  = @acts  ? acts_per_hour.merge!(num_acts_per_hour).sort   : []
      user_data = @users ? users_per_hour.merge!(num_users_per_hour).sort : []

      [act_data, user_data]
    end
  end

  class Daily
    def initialize(demo, start_date, end_date, acts, users)
      @demo = demo
      @start_date = start_date
      @end_date = end_date
      @acts = acts
      @users = users
    end

    def subtitle
      "#{@start_date.to_s(:long)} thru #{@end_date.to_s(:long)}"
    end

    def point_interval
      60 * 60 * 24
    end

    def data_points
      acts_per_day = {}
      users_per_day = {}

      date_range = @start_date..@end_date
      date_range.each { |date| acts_per_day[date.to_date] = users_per_day[date.to_date] = 0 }

      num_acts_per_day = {}
      num_users_per_day = {}

      date_range = Time.zone.local(@start_date.year, @start_date.month, @start_date.day)..Time.zone.local(@end_date.year, @end_date.month, @end_date.day)
      plot_acts = @demo.acts.where(created_at: date_range)

      raw_acts_per_day = plot_acts.group_by { |act| act.created_at.to_date }

      raw_acts_per_day.each do |k,v|
        num_acts_per_day[k] = v.length

        by_user = v.group_by &:user
        num_users_per_day[k] = by_user.keys.length
      end

      act_data  = @acts  ? acts_per_day.merge!(num_acts_per_day).sort   : []
      user_data = @users ? users_per_day.merge!(num_users_per_day).sort : []

      [act_data, user_data]
    end
  end

  class Weekly
    def initialize(demo, start_date, end_date, acts, users)
      @demo = demo
      @start_date = start_date
      @end_date = end_date
      @acts = acts
      @users = users
    end

    def subtitle
      "#{@start_date.to_s(:long)} thru #{@end_date.to_s(:long)} BY WEEK"
    end

    def point_interval
      60 * 60 * 24 * 7
    end

    def data_points
      acts_per_week = {}
      users_per_week = {}

      date_range = @start_date..@end_date
      date_range.step(7) { |date| acts_per_week[date.to_date] = users_per_week[date.to_date] = 0 }

      num_acts_per_week = {}
      num_users_per_week = {}

      date_range = Time.zone.local(@start_date.year, @start_date.month, @start_date.day)..Time.zone.local(@end_date.year, @end_date.month, @end_date.day)
      plot_acts = @demo.acts.where(created_at: date_range)

      raw_acts_per_week = {}

      # Reset the range back to DateTime's. Also, it would be nice if the 'array' 'delete' method worked
      # like it does for hashes (i.e. returns the deleted elements) but since it doesn't...
      # (There might be a single method that can accomplish this, but I couldn't find one.)
      date_range = @start_date..@end_date
      date_range.step(7) do |date|
        partition = plot_acts.partition { |act| act.created_at.to_date < date + 7.days }
        raw_acts_per_week[date] = partition[0]
        plot_acts = partition[1]
      end

      raw_acts_per_week.each do |k,v|
        num_acts_per_week[k] = v.length

        by_user = v.group_by &:user
        num_users_per_week[k] = by_user.keys.length
      end

      act_data  = @acts ? acts_per_week.merge!(num_acts_per_week).sort    : []
      user_data = @users ? users_per_week.merge!(num_users_per_week).sort : []

      [act_data, user_data]
    end
  end
end