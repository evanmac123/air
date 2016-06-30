module Reporting
  module Db
    class Base
      attr_reader :beg_date, :end_date

      def initialize demo_id, beg_date=1.month.ago, end_date=Date.today
        @demo_id  = demo_id
        @demo  = Demo.find(@demo_id)
        @beg_date = beg_date
        @end_date = end_date
      end

     def beg_date= val

     end 

     def beg_date= val

     end 
    end

    class UserActivation < Base

      def total_eligible
        @demo.users.count
      end

      def total_activated 
        memberships.where("users.accepted_invitation_at is not null and users.accepted_invitation_at <= ?", end_date).count
      end

      def newly_activated
        memberships.where("users.accepted_invitation_at >= ? and users.accepted_invitation_at < ?", beg_date, end_date).count
      end

      def activation_pct 
        total_activated/total_eligible
      end


      def memberships
        User.where({}).joins(:board_memberships).where("board_memberships.demo_id" => @demo_id)
      end
    end


    # Pulls unique tile view and completion activity for demo and date range

    class TileActivity < Base

      def available
        @demo.tiles.where("archived_at is null or archived_at > ?", end_date).count
      end

      def posted
        @demo.tiles.where("activated_at >= ? and (archived_at is null or archived_at > ?)", beg_date, end_date).count
      end

      def views
        get_views.count
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

      def get_views
        @demo.tile_viewings.select("user_id,tile_id").where("tile_viewings.created_at >= ? and tile_viewings.created_at < ?", beg_date, end_date)
      end

      def get_completions
        @demo.tile_completions.select("user_id,tile_id").where("tile_completions.created_at >= ? and tile_completions.created_at < ?", beg_date, end_date)
      end

    end

  end
end
