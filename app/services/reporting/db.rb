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


      def wrapper_sql select_for_primary_data
        b = beg_date.to_date.to_s
        e = end_date.to_date.to_s
        <<-SQL 
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

        memberships.find_by_sql(wrapper_sql(qry))
      end

      def activations 
        qry = query_builder(memberships, "users.accepted_invitation_at", "users.id", ["users.accepted_invitation_at is not null and users.accepted_invitation_at <= ?", end_date])

        memberships.find_by_sql(wrapper_sql(qry))
      end


      private


      def memberships
        User.joins(:board_memberships).where("board_memberships.demo_id" => @demo_id)
      end

    end



    class TileActivity < Base

      def posts
        qry = query_builder(@demo.tiles, "tiles.activated_at", "tiles.id", ["activated_at <= ? and (archived_at is null or archived_at > ?)", end_date, end_date])
        @demo.tiles.find_by_sql(wrapper_sql(qry))

      end

      def views
        qry = query_builder(@demo.tile_viewings, "tile_viewings.created_at", "tile_viewings.id", ["tile_viewings.created_at >= ? and tile_viewings.created_at < ?", beg_date, end_date])
        @demo.tile_viewings.find_by_sql(wrapper_sql(qry))

      end

      def completions
        qry = query_builder(@demo.tile_completions, "tile_completions.created_at", "tile_completions.id", ["tile_completions.created_at >= ? and tile_completions.created_at < ?", beg_date, end_date])
        @demo.tile_completions.find_by_sql(wrapper_sql(qry))
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

