class PlotData
  attr_reader :period, :tile
  delegate  :time_unit, 
            :start_date,
            :end_date,
            :point_interval,
            to: :period

  def initialize tile, period, action_type, value_type
    @tile = tile
    @period = period
    @action_type = action_type
    @value_type = value_type
  end

  def data
    case @value_type
    when 'cumulative'
      cumulative
    when 'activity'
      activity
    end
  end

  protected
    def cumulative
      start = q_start_date
      stop  = q_end_date
      filled_actions = grouped_actions
      while start < stop
        filled_actions[start] = filled_actions[start].to_i + filled_actions[start - point_interval].to_i
        start += point_interval
      end
      filled_actions.values
    end

    def activity
      start = q_start_date
      stop  = q_end_date
      filled_actions = grouped_actions
      while start < stop
        filled_actions[start] = filled_actions[start].to_i
        start += point_interval
      end
      filled_actions.values
    end

    def q_start_date
      start_date(:time).beginning_of_day
    end

    def q_end_date
      end_date(:time).end_of_day
    end

    def grouped_actions
      # => {"2015-08-19 11:00:00"=>12, "2015-08-19 10:00:00"=>27, "2015-08-19 13:00:00"=>1}
      case @action_type
      when 'unique_views'
        unique_views
      when 'total_views'
        total_views
      when 'interactions'
        interactions
      end
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
