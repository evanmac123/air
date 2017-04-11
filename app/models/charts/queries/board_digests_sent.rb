class Charts::Queries::BoardDigestsSent < Charts::Queries::BoardQuery
  def query
    board.tiles_digests.group_by_period(time_unit, :created_at).count
  end

  def cache_key
    "#{board.id}:digests_sent:#{time_unit}"
  end
end
