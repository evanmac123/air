class Query::BoardTilesCreated < Query::BoardQuery
  def query
    board.tiles.group(:creation_source_cd).group_by_period(time_unit, :created_at).count
  end

  def cache_key
    "#{board.id}:tiles_created:#{time_unit}"
  end

  def analysis_from_cached_query(start_date, end_date, scoped_enum = nil)
    data = cached_query.select do |k, _v|
      in_scope?(k[0], scoped_enum) && in_range?(k[1], start_date, end_date)
    end
    ungroup_sources(data)
  end

  def in_range?(date, start_date, end_date)
    date >= start_date.to_date && date <= end_date.to_date
  end

  def in_scope?(current_scope, scoped_enum)
    return true if scoped_enum.nil?
    current_scope == scoped_enum
  end

  def ungroup_sources(grouped_data)
    grouped_data.inject({}) { |hsh, (k, v)|
      key = k[1]

      if hsh[key].nil?
        hsh[key] = v
      else
        hsh[key] += v
      end

      hsh
    }
  end
end
