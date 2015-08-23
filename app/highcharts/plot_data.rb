class PlotData
  attr_reader :period, :tile
  delegate  :time_unit,
            :start_date,
            :end_date,
            :q_start_date,
            :q_end_date,
            :point_interval,
            to: :period

  def initialize tile, period, action_type, value_type
    @tile = tile
    @period = period
    @action_type = action_type
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
      # => {"2015-08-19 11:00:00"=>12, "2015-08-19 10:00:00"=>27, "2015-08-19 13:00:00"=>1}
      self.send @action_type.to_sym
    end

    def total_views
      tile.tile_viewings
          .select("date_trunc('#{time_unit}', created_at), views")
          .where(created_at: q_start_date..q_end_date)
          .group("date_trunc('#{time_unit}', created_at)")
          .sum(:views)
    end

    def unique_views
      tile.tile_viewings
          .select("date_trunc('#{time_unit}', created_at)")
          .where(created_at: q_start_date..q_end_date)
          .group("date_trunc('#{time_unit}', created_at)")
          .count
    end

    def interactions
      tile.tile_completions
          .select("date_trunc('#{time_unit}', created_at)")
          .where(created_at: q_start_date..q_end_date)
          .group("date_trunc('#{time_unit}', created_at)")
          .count
    end
end
