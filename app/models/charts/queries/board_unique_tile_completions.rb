class Charts::Queries::BoardUniqueTileCompletions < Charts::Queries::BoardQuery
  def query
    board.tile_completions.group_by_period(time_unit, "tile_completions.created_at").count
  end

  def cache_key
    "#{board.id}:unique_tile_completions:#{time_unit}"
  end
end
