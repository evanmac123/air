class Period
  INTERVAL_TYPES = ['monthly', 'weekly', 'daily', 'hourly'].freeze

  def initialize interval_type, start_date, end_date
    @interval_type = interval_type
    @start_date = from_american_format start_date
    @end_date = from_american_format end_date
  end

  def point_interval
    case @interval_type
    when 'monthly'
      1.month
    when 'weekly'
      1.week
    when 'daily'
      1.day
    when 'hourly'
      1.hour
    end
  end

  def point_interval_unit
    if @interval_type == 'monthly'
      "month"
    else
      nil
    end
  end

  def time_unit
    case @interval_type
    when 'monthly'
      "month"
    when 'weekly'
      "week"
    when 'daily'
      "day"
    when 'hourly'
      "hour"
    end
  end

  def start_date format = :american
    show_date @start_date, format
  end

  def end_date format = :american
    show_date @end_date, format
  end

  def points
    if @points
      return @points
    else
      @points = []
    end

    each_point do |point|
      @points.push point
    end
    @points
  end

  def each_point
    curr_point = q_start_date.send ("beginning_of_" + time_unit).to_sym
    stop_point  = q_end_date

    while curr_point <= stop_point
      yield show_date(curr_point, :utc_str)
      curr_point = curr_point + point_interval
    end
  end

  def q_start_date
    start_date(:time).beginning_of_day
  end

  def q_end_date
    end_date(:time).end_of_day
  end

  def show_date time, format
    case format
    when :date
      date = time.to_date
      if time_unit == 'week'
        date.send(:"beginning_of_#{time_unit}")
      elsif time_unit == 'month'
        date.send(:"beginning_of_#{time_unit}")
      else
        date
      end
    when :american
      time.to_s(:chart_start_end_day)
    when :time
      time
    when :american_long
      time.strftime("%b %d, %Y")
    when :utc_str
      time.utc.to_s[0..-5]
    when :utc_time
      time += " UTC" unless time.include? "UTC"
      Time.parse time
    end
  end

  protected

    def from_american_format str
      time = Time.strptime(str, "%b %d, %Y")
      (time + time.utc_offset).utc # same time in utc
    end
end
