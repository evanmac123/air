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
      end


      private
      def aggregation interval_field, key_field

        "DATE_TRUNC('#{@interval}', #{interval_field}) AS interval, count(#{key_field}) as interval_count, sum(count(#{key_field})) " +
          " over (order by date_trunc('#{@interval}', #{interval_field})) as cumulative_count"
      end

      def group_and_order relation
        relation.group("interval").order("interval")
      end


      def sql
        b = beg_date.to_date.to_s
        e = end_date.to_date.to_s
        query = <<-SQL

         WITH reporting_period AS (
          SELECT generate_series(date_trunc('week', date '#{b}'), date_trunc('week', date '#{e}'), interval '1 week') 
          AS interval
         ),

        bms AS (
         SELECT users.created_at, board_memberships.demo_id 
         FROM board_memberships JOIN users ON users.id = board_memberships.user_id 
         WHERE demo_id=#{@demo.id}
        )

        SELECT date(interval) AS interval
        , count(bms.created_at) AS interval_count 
        , sum(count( bms.created_at) ) OVER (order by date_trunc('week', bms.created_at)) AS cumulative_count 

        FROM reporting_period 

        LEFT JOIN bms 

        ON interval=date(date_trunc('week', bms.created_at) )

        GROUP BY interval, date_trunc('week', bms.created_at) ORDER BY interval

        SQL
        query
      end 


    end

    class UserActivation < Base

      def eligibles
        User.find_by_sql(sql)
      end

      def activations 

        agg_clause = aggregation "users.accepted_invitation_at", "users.id"
       group_and_order( memberships.select(agg_clause).where("users.accepted_invitation_at is not null and users.accepted_invitation_at <= ?", end_date))
      end

      #def activation_pct 
        #total_activated/total_eligible
      #end

      private

      def memberships
        User.joins(:board_memberships).where("board_memberships.demo_id" => @demo_id)
      end

    end



    class TileActivity < Base

      def posts
        agg_clause = aggregation "activated_at", "id"
        group_and_order(@demo.tiles.select(agg_clause).where("activated_at <= ? and (archived_at is null or archived_at > ?)", end_date, end_date))
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
