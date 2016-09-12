class GridQuery::BoardActions
  attr_reader :board, :query_type, :tile_ids
  GRID_TYPES = {
    "live" => "Live",
    "interacted" => "Interacted",
    "viewed_only" => "Viewed only",
    "all" => "All"
  }.freeze

  def initialize board, query_type
    @board = board
    @tile_ids = board.tiles.pluck(:id)
    @query_type = query_type
  end

  def query
    self.send(query_type.to_sym)
  end

  protected
    def live
      scoped.where{ board_tile_viewings.id != nil }
    end

    def all
      scoped.where{ board_tile_viewings.id != nil }
    end

    def viewed_only
      scoped.where{ board_tile_viewings.id != nil }.where{ tile_completions.id == nil }
    end

    def interacted
      scoped.where{ board_tile_viewings.id != nil }.where{ tile_completions.id != nil }
    end

    def scoped
      users_viewings_subquery = board.tile_viewings.select(["tile_viewings.*", "tiles.headline AS headline"]).includes(:tile).where(user_type: 'User')

      users_completions_subquery = board.tile_completions.where(user_type: 'User')

      board.users.
        joins do
          "LEFT JOIN (" +
          users_viewings_subquery.to_sql +
          ") AS board_tile_viewings " +
          "ON board_tile_viewings.user_id = users.id"
        end.
        joins do
          "LEFT JOIN (" +
           users_completions_subquery.to_sql +
          ") AS tile_completions " +
          "ON tile_completions.user_id = users.id AND tile_completions.tile_id = board_tile_viewings.tile_id"
        end.
        select(
          "users.id AS user_id, \
           users.name AS user_name, \
           users.email AS user_email, \
           board_tile_viewings.views AS tile_views, \
           board_tile_viewings.updated_at AS tile_views_updated_at, \
           board_tile_viewings.headline AS tile_headline, \
           tile_completions.created_at AS completion_date"
        )
    end
end
