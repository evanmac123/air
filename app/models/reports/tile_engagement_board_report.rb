class Reports::TileEngagementBoardReport < Reports::BoardReport

  def attributes
    {
      unique_views: unique_views_count,
      total_views: total_views_count,
      interactions: interactions_count,
    }
  end

  private
    def tile_viewings
      @tile_viewings ||= board.tile_viewings.select([:views, :created_at]).where("tile_viewings.created_at >= ? and tile_viewings.created_at <= ?", from_date, to_date)
    end

    def unique_views_count
      tile_viewings.count
    end

    def total_views_count
      tile_viewings.sum("tile_viewings.views")
    end

    def interactions_count
      board.tile_completions.select(:created_at).where("tile_completions.created_at BETWEEN ? and ?", from_date, to_date).count
    end
end
