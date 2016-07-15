module Reporting
  module Db
    class Base
      attr_reader :beg_date, :end_date

      def initialize demo_id, beg_date, end_date, interval
        @demo_id  = demo_id
        @demo  = Demo.find(@demo_id)
        @beg_date = beg_date.beginning_of_week
        @end_date = end_date.beginning_of_week
        @interval = interval
        @series_interval=(interval == "quarter") ? "3 months" : "1 #{interval}"
      end


      protected

      def query_builder relation, interval_field, key_field, condition

        relation
          .select(count_by_interval(interval_field, key_field))
          .where(condition)
          .to_sql
      end

      def count_by_interval interval_field, key_field
        "DATE_TRUNC('#{@interval}', #{interval_field}) AS INTERVAL, COUNT(#{key_field}) AS interval_count"
      end

      def aggregation interval_field, key_field

        "DATE_TRUNC('#{@interval}', #{interval_field}) AS interval, count(#{key_field}) as interval_count, sum(count(#{key_field})) " +
          " over (order by date_trunc('#{@interval}', #{interval_field})) as cumulative_count"
      end

      def group_and_order relation
        relation.group("interval").order("interval")
      end


      def sql interval_field, key_field, conditions
        b = beg_date.to_date.to_s
        e = end_date.to_date.to_s
        qry=<<-SQL 
                 SELECT
                 interval
                 , interval_count 
                 , SUM(interval_count ) OVER (ORDER BY interval) AS cumulative_count 
                 
                 FROM
                 (
                 SELECT interval, MAX(interval_count) AS interval_count FROM
                 (
                   SELECT GENERATE_SERIES(DATE(DATE_TRUNC('#{@interval}', date '#{b}')), DATE(DATE_TRUNC('#{@interval}', date '#{e}')), interval '#{@series_interval}') AS interval,0 AS interval_count
                   union 
                 
                   SELECT DATE_TRUNC('#{@interval}', #{interval_field}) AS INTERVAL, COUNT(#{key_field}) AS interval_count 
                   FROM users JOIN board_memberships bm ON bm.user_id = users.id AND bm.demo_id = #{@demo.id} 
                   WHERE #{conditions}
                   GROUP BY 1 ORDER BY 1 
                 ) sub1
                 GROUP BY interval
                 ) grouped_data
        SQL
      end
   def sql2 select_for_primary_data
        b = beg_date.to_date.to_s
        e = end_date.to_date.to_s
        qry=<<-SQL 
                 SELECT
                 interval
                 , interval_count 
                 , SUM(interval_count ) OVER (ORDER BY interval) AS cumulative_count 
                 
                 FROM
                 (
                 SELECT interval, MAX(interval_count) AS interval_count FROM
                 (
                   SELECT GENERATE_SERIES(DATE(DATE_TRUNC('#{@interval}', date '#{b}')), DATE(DATE_TRUNC('#{@interval}', date '#{e}')), interval '#{@series_interval}') AS interval,0 AS interval_count
                   union 

                   #{select_for_primary_data}
                 
                   GROUP BY 1 ORDER BY 1 
                 ) sub1
                 GROUP BY interval
                 ) grouped_data
        SQL
      end

    end

    class UserActivation < Base

      def eligibles

        qry = query_builder(memberships, "users.created_at", "users.created_at", ["users.created_at < ?", end_date])

        User.find_by_sql(sql2(qry))
      end

      def activations 
        qry = query_builder(memberships, "users.accepted_invitation_at", "users.id", ["users.accepted_invitation_at is not null and users.accepted_invitation_at <= ?", end_date])

        User.find_by_sql(sql2(qry))
      end


      private


      def memberships
        User.joins(:board_memberships).where("board_memberships.demo_id" => @demo_id)
      end

    end



    class TileActivity < Base

      def posts
        qry = query_builder(@demo.tiles, "tiles.activated_at", "tiles.id", ["activated_at <= ? and (archived_at is null or archived_at > ?)", end_date, end_date])

        Tile.find_by_sql(sql2(qry))
      end

      def views
        agg_clause = aggregation "tile_viewings.created_at", "tile_viewings.id"
        group_and_order(@demo.tile_viewings.select(agg_clause).where("tile_viewings.created_at >= ? and tile_viewings.created_at < ?", beg_date, end_date))
      end

      def completions
        agg_clause = aggregation "tile_completions.created_at", "tile_completions.id"
        group_and_order(@demo.tile_completions.select(agg_clause).where("tile_completions.created_at >= ? and tile_completions.created_at < ?", beg_date, end_date))
      end

      def views_over_available
        views/available
      end

      def completions_over_views
        completions/views
      end


    end

  end
end

