class TileStatsChartForm
  include ActiveModel::Conversion

  ACTION_TYPES = ['unique_views', 'total_views', 'interactions'].freeze
  INTERVAL_TYPES = ['monthly', 'weekly', 'daily', 'hourly'].freeze
  VALUE_TYPES = ['cumulative', 'activity'].freeze
  DATE_RANGE_TYPES = ['past_week', 'past_30_days', "past_3_months", "past_12_months", "pick_a_date_range"]

  attr_reader :tile, :action_type, :interval_type, :value_type, :date_range_type, :start_date, :end_date

  def initialize tile, params = {}
    @tile = tile
    @action_type = params[:action_type] || ACTION_TYPES[0]
    @interval_type = params[:interval_type] || INTERVAL_TYPES[0]
    @value_type = params[:value_type] || VALUE_TYPES[0]
    @date_range_type = params[:date_range_type]
    @start_date = params[:start_date] || (Time.now - 1.day).to_s(:chart_start_end_day) #tile.created_at.to_s(:chart_start_end_day)
    @end_date = params[:end_date] || Time.now.to_s(:chart_start_end_day)
  end

  def date_range_types_disabled_option
    start_date = tile.created_at
    end_date = Time.now
    start_date_str = start_date.strftime("%b %d, %Y")
    end_date_str = end_date.strftime("%b %d, %Y")
    start_date_str + " - " + end_date_str
  end

  def date_range_types_select_list
    ([date_range_types_disabled_option] + DATE_RANGE_TYPES).collect{ |name| [ name.humanize, name ] }
  end

  def self.interval_types_select_list
    INTERVAL_TYPES.collect {|name| [ name.capitalize, name ] }
  end

  def self.value_types_select_list
    VALUE_TYPES.collect {|name| [ name.capitalize, name ] }
  end

  # Form specific methods:
  def self.model_name
    ActiveModel::Name.new(TileStatsChartForm)
  end

  def persisted?
    false
  end
end
