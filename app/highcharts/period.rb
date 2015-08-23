class Period
  INTERVAL_TYPES = ['monthly', 'weekly', 'daily', 'hourly'].freeze

  def initialize interval_type, start_date, end_date
    @interval_type = interval_type
    @start_date = from_american_format start_date
    @end_date = from_american_format end_date
  end

  def x_axis_label_format
    case @interval_type
    when 'monthly'
      "%b. %d"
    when 'weekly'
      "%b. %d"
    when 'daily'
      "%b. %d"
    when 'hourly'
      "%l %p"
    end
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

  def each_point
    curr_point = q_start_date
    stop_point  = q_end_date

    while curr_point <= stop_point
      yield curr_point
      curr_point += point_interval
    end
  end

  def q_start_date
    start_date(:time).beginning_of_day
  end

  def q_end_date
    end_date(:time).end_of_day
  end

  protected
    def show_date time, format
      if :date
        time.to_date
      elsif :american
        time.to_s(:chart_start_end_day)
      elsif :time
        time
      elsif :american_long
        time.strftime("%b %d, %Y")
      end
    end

    def from_american_format str
      Time.strptime(str, "%m/%d/%Y")
    end
end
