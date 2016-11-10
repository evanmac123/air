require 'reporting/db/by_board'
module Reporting
  module Db
    class TileActivity < ByBoard

      def posts
        qry = query_builder(@demo.tiles, "tiles.activated_at", "tiles.id", ["activated_at <= ? and (archived_at is null or archived_at > ?)", end_date, end_date])
        @demo.tiles.find_by_sql(wrapper_sql(qry))
      end

      def views
        qry = query_builder(@demo.tile_viewings, "tile_viewings.created_at", "tile_viewings.id", ["tile_viewings.created_at < ?", end_date])
        @demo.tile_viewings.find_by_sql(wrapper_sql(qry))
      end

      def completions
        qry = query_builder(@demo.tile_completions, "tile_completions.created_at", "tile_completions.id", ["tile_completions.created_at >= ? and tile_completions.created_at < ?", beg_date, end_date])
        @demo.tile_completions.find_by_sql(wrapper_sql(qry))
      end

    end
  end
end
