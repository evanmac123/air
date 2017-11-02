class Charts::ChartBase
  MIXPANEL_TIME_LIMIT = 1824.days.ago

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def attributes(list_of_series)
    {
      series: get_requested_series(list_of_series)
    }
  end

  def get_requested_series(list_of_series)
    list_of_series.map { |s|
      {
        data: self.send(s)
      }
    }
  end

  def time_unit
    params[:interval_type].to_sym
  end

  def start_date
    @start_date ||= get_start_date
  end

  def get_start_date
    date = start_date_based_on_time_unit

    if date < MIXPANEL_TIME_LIMIT
      MIXPANEL_TIME_LIMIT
    else
      date
    end
  end

  def start_date_based_on_time_unit
    date = params[:start_date].try(:to_time)

    if time_unit == :quarter
      date.beginning_of_quarter
    elsif time_unit == :month
      date.beginning_of_month
    else
      date.beginning_of_week
    end
  end

  def end_date
    params[:end_date].try(:to_time) || Time.current
  end

  def board_from_params
    Demo.find(params[:demo_id])
  end

  def tile_from_params
    params[:tile] || Tile.find(params[:tile_id])
  end

  def cumulative_data(data)
    sum = 0
    data.map { |plot| [plot[0], sum += plot[1]] }
  end
end
