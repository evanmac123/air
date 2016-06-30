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
    end

    class UserActivation < Base

      def total_eligible
        @demo.users.count
      end

      def total_activated 
        memberships.select(cumulative_clause).where("users.accepted_invitation_at is not null and users.accepted_invitation_at <= ?", end_date).group("interval")
      end

      def newly_activated
        memberships.select(clause).where("users.accepted_invitation_at >= ? and users.accepted_invitation_at < ?", beg_date, end_date).group("interval")
      end

      def activation_pct 
        total_activated/total_eligible
      end


      def memberships
        User.where({}).joins(:board_memberships).where("board_memberships.demo_id" => @demo_id)
      end

      def clause
        "DATE_TRUNC('#{@interval}', accepted_invitation_at) AS interval, count(users.id) AS count"
      end

      def cumulative_clause
        "DATE_TRUNC('#{@interval}', accepted_invitation_at) AS interval, sum(count(users.id)) " +
          " over (order by date_trunc('#{@interval}',accepted_invitation_at)) as count"
      end



    end


    # Pulls unique tile view and completion activity for demo and date range

    class TileActivity < Base

      def available
        @demo.tiles.select(cumulative_clause).where("activated_at <= ? and (archived_at is null or archived_at > ?)", end_date, end_date).group("interval")
      end

      def posted
        @demo.tiles.select(clause).where("activated_at >= ? and (archived_at is null or archived_at > ?)", beg_date, end_date).group("interval").order("interval")
      end

      def views
        @demo.tile_viewings.select(view_clause).where("tile_viewings.created_at >= ? and tile_viewings.created_at < ?", beg_date, end_date).group("interval")
      end

      def completions
        get_completions.count
      end

      def views_over_available
        views/available
      end

      def completions_over_views
        completions/views
      end

      private


      def clause
        "DATE_TRUNC('#{@interval}', activated_at) AS interval, count(id) AS count"
      end

      def cumulative_clause
        "DATE_TRUNC('#{@interval}', activated_at) AS interval, sum(count(id)) " +
          " over (order by date_trunc('#{@interval}',activated_at)) as count"
      end

      def view_clause
        "DATE_TRUNC('#{@interval}', tile_viewings.created_at) AS interval, count(tile_viewings.id) AS count"
      end

      def completion_clause
        "user_id,tile_id #{cumulative_clause}"
      end




      def get_views
      end

      def get_completions
        @demo.tile_completions.select("user_id,tile_id").where("tile_completions.created_at >= ? and tile_completions.created_at < ?", beg_date, end_date)
      end

    end

  end
end
