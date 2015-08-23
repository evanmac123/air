class Query::TotalViews
  attr_reader :tile, :period
  delegate  :time_unit,
            :q_start_date,
            :q_end_date,
            to: :period
            
  def initialize tile, period
    @tile = tile
    @period = period
  end

  def query
    tile.tile_viewings
        .select("date_trunc('#{time_unit}', created_at), views")
        .where(created_at: q_start_date..q_end_date)
        .group("date_trunc('#{time_unit}', created_at)")
        .sum(:views)
  end
end
