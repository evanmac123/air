class Query::UniqueViews < Query::TileQuery
  def raw_query
    tile.tile_viewings
        .select("date_trunc('#{time_unit}', created_at)")
        .where(created_at: q_start_date..q_end_date)
        .group("date_trunc('#{time_unit}', created_at)")
        .count
  end
end
