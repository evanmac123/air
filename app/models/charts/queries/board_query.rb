class Charts::Queries::BoardQuery
  attr_reader :board, :time_unit

  def initialize(demo, time_unit = :week)
    @board = demo
    @time_unit = time_unit
  end

  def set_cached_query
    Rails.cache.delete(cache_key)
    cached_query
  end

  def cached_query
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      query
    end
  end

  def query
    raise "Implement in subclass."
  end

  def cache_key
    raise "Implement in subclass."
  end

  def analysis_from_cached_query(start_date, end_date)
    cached_query.select do |k, _v|
      k >= start_date.to_date && k <= end_date.to_date
    end
  end

  def total(start_date = nil, end_date = nil)
    if start_date && end_date
      analysis_from_cached_query(start_date, end_date).values.inject(:+)
    else
      cached_query.values.inject(:+)
    end
  end
end
