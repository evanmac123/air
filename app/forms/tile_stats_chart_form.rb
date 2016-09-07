class TileStatsChartForm < LineChartReportForm 

  def initialize tile, params = {}
    super
    @period = Period.new(interval_type, start_date, end_date)
    @action_query = ("Query::" + action_type.camelize).constantize.new(tile, @period)
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

  def data
    PlotData.new( @period, @action_query, @value_type)
  end


  # Implements ActiveModel methods

  def self.model_name
    ActiveModel::Name.new(TileStatsChartForm)
  end


end
