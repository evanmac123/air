class GridQuery::TileActions
  attr_reader :tile, :query_type
  # query_type: all, viewed, not_viewed, viewed_and_interacted, viewed_and_not_interacted

  def initialize tile, query_type
    @tile = tile
    @query_type = query_type
  end

  def query
    self.send(query_type)
  end

  protected
    def viewed_and_not_interacted
      all.where{ tile_viewings.id != nil }.where{ tile_completions.id == nil }
    end

    def viewed_and_interacted
      all.where{ tile_viewings.id != nil }.where{ tile_completions.id != nil }
    end

    def not_viewed
      all.where{ tile_viewings.id == nil }
    end

    def viewed
      all.where{ tile_viewings.id != nil }
    end

    def all
      users_viewings_subquery = TileViewing.users_viewings(tile.id)
      users_completions_subquery = TileCompletion.where(tile_id: tile.id, user_type: 'User')

      tile.demo.users.
        joins do
          "LEFT JOIN (" +
           users_completions_subquery.to_sql +
          ") AS tile_completions " +
          "ON tile_completions.user_id = users.id"
        end.
        joins do
          "LEFT JOIN (" +
           users_viewings_subquery.to_sql +
          ") AS tile_viewings " +
          "ON tile_viewings.user_id = users.id"
        end.
        select(
          "users.id AS user_id, \
           users.name AS user_name, \
           users.email AS user_email, \
           tile_viewings.views AS tile_views, \
           tile_completions.answer_index AS tile_answer_index, \
           tile_completions.created_at AS completion_date"
        )
    end
end
