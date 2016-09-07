class TileStatsChartForm < LineChartReportForm

  def initialize tile, params = {}
    @tile = tile
    super params

    @action_query = ("Query::" + action_type.camelize).constantize.new(tile, period)
  end

  def tile
    @tile
  end

  def action_types
   ['unique_views', 'total_views', 'interactions']
  end

  def action_num action
    tile.send(action.to_sym)
  end

  def action_type_class action
    action + " " + (action == action_type ? "selected" : "")
  end

  def plot_data
    PlotData.new( period, @action_query, @value_type)
  end

  # Implements ActiveModel methods

  def self.model_name
    ActiveModel::Name.new(TileStatsChartForm)
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
