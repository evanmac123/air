class BoardStatsLineChartForm < LineChartReportForm
  def initialize demo, params = {}
    @demo = demo
    super params
  end

  def action_types
   ['unique_views', 'total_views', 'interactions']
  end

  def plot_data
    
  end

  # Implements ActiveModel methods

  def self.model_name
    ActiveModel::Name.new(TileStatsChartForm)
  end

  private

  def pull_data

    @res =ClientUsage.new({demo:@demo.id, start: 12.weeks.ago, interval: "week"}).data
  end

end
