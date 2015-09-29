class Query::TotalViews < Query::TileQuery
  def raw_query
    tile.tile_viewings
        .select("date_trunc('#{time_unit}', created_at), views")
        .where(created_at: q_start_date..q_end_date)
        .group("date_trunc('#{time_unit}', created_at)")
        .sum(:views)
  end
end
