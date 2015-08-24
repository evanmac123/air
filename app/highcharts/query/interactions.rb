class Query::Interactions < Query::TileQuery
  def query
    tile.tile_completions
        .select("date_trunc('#{time_unit}', created_at)")
        .where(created_at: q_start_date..q_end_date)
        .group("date_trunc('#{time_unit}', created_at)")
        .count
  end
end
