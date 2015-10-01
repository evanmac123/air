class Query::TileQuery
  attr_reader :tile, :period
  delegate  :time_unit,
            :q_start_date,
            :q_end_date,
            :show_date,
            to: :period

  def initialize tile, period
    @tile = tile
    @period = period
  end

  def query
    raw_query
  end

  def raw_query
    {}
  end
end