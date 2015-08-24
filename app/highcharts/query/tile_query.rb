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
    Hash[raw_query.map { |date_str, v| [show_date(date_str, :utc_time), v] }]
  end

  def raw_query
    {}
  end
end
