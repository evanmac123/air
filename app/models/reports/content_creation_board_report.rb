class Reports::ContentCreationBoardReport < Reports::BoardReport

  def attributes
    {
      tiles_posted: tiles_posted_count,
      created: created_percent,
      explore: explore_percent,
      suggestion_box: suggestion_box_percent
    }
  end

  private

    def tiles_source_hash
      board.tiles.select([:creation_source_cd, :created_at]).where("tiles.activated_at >= ? and tiles.activated_at <= ?", from_date, to_date).group(:creation_source_cd).count
    end

    def tiles_posted_count
      tiles_source_hash.values.inject(:+)
    end

    def created_percent
      percent_finder(Tile.client_admin_created)
    end

    def explore_percent
      percent_finder(Tile.explore_created)
    end

    def suggestion_box_percent
      percent_finder(Tile.suggestion_box_created)
    end

    def percent_finder(creation_source)
      if tiles_source_hash[creation_source] && tiles_posted_count && tiles_posted_count > 0
        (tiles_source_hash[creation_source] / tiles_posted_count.to_f).round(4)
      else
        0.00
      end
    end
end
