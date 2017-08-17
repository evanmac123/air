class GridQuery::TileActions
  attr_reader :tile, :query_type, :answer_filter
  # query_type: all, viewed, not_viewed, viewed_and_interacted, viewed_and_not_interacted
  GRID_TYPES = {
    "live" => "Live",
    "interacted" => "Interacted",
    "viewed_only" => "Viewed only",
    "not_viewed" => "Didn't view",
    "free_response" => "Free Response",
    "all" => "All"
  }.freeze

  def initialize tile, query_type, answer_filter = nil
    @tile = tile
    @query_type = query_type
    @answer_filter = answer_filter
  end

  def query
    result = self.send(query_type.to_sym)
    if answer_filter
      index = answer_index
      result.where{tile_completions.answer_index == index}
    else
      result
    end
  end

  protected
    def answer_index
      tile.multiple_choice_answers.index(answer_filter)
    end

    def live
      all.where{ tile_viewings.id != nil }
    end

    def viewed_only
      all.where{ tile_viewings.id != nil }.where{ tile_completions.id == nil }
    end

    def interacted
      all.where{ tile_viewings.id != nil }.where{ tile_completions.id != nil }
    end

    def not_viewed
      all.where{ tile_viewings.id == nil }
    end

    def free_response
      all.where{tile_completions.free_form_response !=""}
    end

    def all
      users_viewings_subquery = TileViewing.users_viewings(tile.id).to_sql
      users_completions_subquery = TileCompletion.where(tile_id: tile.id, user_type: 'User').to_sql

      tile.demo.users.
        joins do
          "LEFT JOIN (" +
           users_completions_subquery +
          ") AS tile_completions " +
          "ON tile_completions.user_id = users.id"
        end.
        joins do
          "LEFT JOIN (" +
           users_viewings_subquery +
          ") AS tile_viewings " +
          "ON tile_viewings.user_id = users.id"
        end.
        select(
          "users.id AS user_id, \
           users.name AS user_name, \
           users.email AS user_email, \
           tile_viewings.views AS tile_views, \
           tile_viewings.created_at AS viewed_date, \
           tile_completions.answer_index AS tile_answer_index, \
           tile_completions.created_at AS completion_date, \
           tile_completions.free_form_response AS free_response"
        )
    end
end
