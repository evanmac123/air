class PlotData
  attr_reader :period, :tile, :action_query
  delegate  :point_interval, to: :period

  def initialize period, action_query, value_type
    @period = period
    @action_query = action_query
    @value_type = value_type
  end

  def data
    @filled_actions = grouped_actions
    period.each_point do |point|
      @filled_actions[point] = value_in_point point
    end
    @filled_actions.values
  end

  protected
    def value_in_point point
      value = @filled_actions[point].to_i
      if @value_type == 'cumulative'
        value += @filled_actions[point - point_interval].to_i
      end
      value
    end

    def grouped_actions
      # i.e. hourly:
      # => {"2015-08-19 11:00:00"=>12, "2015-08-19 10:00:00"=>27, "2015-08-19 13:00:00"=>1}
      action_query.query
    end
end
