class Charts::Queries::TileQuery
  attr_reader :tile, :time_unit

  def initialize(tile, time_unit = :hour)
    @tile = tile
    @time_unit = time_unit
  end

  def set_cached_query
    Rails.cache.delete(cache_key)
    cached_query
  end

  def cached_query
    # Rails.cache.fetch(cache_key) do
      query.to_a
    # end
  end

  def chart_end_date
    chart_start_date.beginning_of_day + 2.days
  end

  def chart_start_date
    tile.tile_viewings.order(:created_at).limit(10).last.try(:created_at) || tile.sent_at || tile.activated_at || tile.created_at
  end

  def tile_stats_chart_range
    (chart_start_date - 3.hours)..chart_end_date
  end
end
