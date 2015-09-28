class TileStatsChartForm
  include ActiveModel::Conversion

  ACTION_TYPES = ['unique_views', 'total_views', 'interactions'].freeze
  VALUE_TYPES = ['cumulative', 'activity'].freeze

  attr_reader :tile,
              :time_handler,
              :action_type,
              :value_type,
              :new_chart

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
    @action_type = params.delete(:action_type) || ACTION_TYPES[0]
    @value_type = params.delete(:value_type) || VALUE_TYPES[0]
    params = initial_params if params.empty?
    @new_chart = params[:new_chart]
    @time_handler = TimeHandler.new(
      params.slice(:interval_type, :start_date, :end_date, :date_range_type, :changed_field, :new_chart)
    ).handle
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
        start_date: tile.created_at.strftime("%b %d, %Y"),
        end_date: Time.now.strftime("%b %d, %Y"),
        changed_field: 'end_date', # to trigger time handler
        new_chart: true
      }
    end
end
