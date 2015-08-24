class TileStatsChartForm
  include ActiveModel::Conversion

  ACTION_TYPES = ['unique_views', 'total_views', 'interactions'].freeze
  VALUE_TYPES = ['cumulative', 'activity'].freeze

  attr_reader :tile,
              :time_handler,
              :action_type,
              :value_type

  delegate  :interval_type,
            :date_range_type,
            :start_date,
            :end_date,
            :date_range_types_disabled_option,
            :date_range_types_select_list,
            :show_dates_selection,
            :show_date_range,
            to: :time_handler

  def initialize tile, params = {}
    @tile = tile
    params = initial_params if params.empty?
    @time_handler = TimeHandler.new(
      params.slice(:interval_type, :start_date, :end_date, :date_range_type, :changed_field)
    ).handle
    @action_type = params[:action_type] || ACTION_TYPES[0]
    @value_type = params[:value_type] || VALUE_TYPES[0]
  end

  def changed_field
    nil
  end

  def action_num action
    tile.send(action.to_sym)
  end

  def action_type_class action
    action + " " + (action == action_type ? "selected" : "")
  end

  def chart_params
    period = Period.new(interval_type, start_date, end_date)
    action_query = ("Query::" + action_type.camelize).constantize.new(tile, period)
    [period, action_query, @value_type]
  end

  def self.interval_types_select_list
    Period::INTERVAL_TYPES.collect {|name| [ name.capitalize, name ] }
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

  protected
    def initial_params
      {
        start_date: tile.created_at.to_s(:chart_start_end_day),
        end_date: Time.now.to_s(:chart_start_end_day),
        changed_field: 'end_date' # to trigger time handler
      }
    end
end
