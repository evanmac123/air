module Reporting
  module Db
    class Base
      attr_accessor :beg_date, :end_date

      def initialize demo_id, beg_date=1.month.ago, end_date=Date.today
        @demo_id  = demo_id
        @demo  = Demo.find(@demo_id)
        @beg_date = beg_date
        @end_date = end_date
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

      def activation_percent 
        all_activated_as_of(end_date)/total_eligible
      end


      def memberships
        User.where({}).joins(:board_memberships).where("board_memberships.demo_id" => @demo_id)
      end
    end


    # Pulls unique tile view and completion activity for demo and date range

    class TileActivity < Base

      def tiles_available
        @demo.tiles.where("archived_at is null or archived_at > ?", end_date).count
      end

      def tiles_posted
        @demo.tiles.where("activated_at >= ? and (archived_at is null or archived_at > ?)", beg_date, end_date).count
      end

      def tile_views
        views.count
      end

      def tile_completions
        completions.count
      end

      def tiles_viewed_conversion
        unique_tile_views_count/tiles_posted_count
      end

      def tile_interaction_conversion
        unique_tile_views_count/unique_tile_completions_count
      end

      private

      def views
        @demo.tile_viewings.select("user_id,tile_id").where("tile_viewings.created_at >= ? and tile_viewings.created_at < ?", beg_date, end_date)
      end

      def completions
        @demo.tile_completions.select("user_id,tile_id").where("tile_completions.created_at >= ? and tile_completions.created_at < ?", beg_date, end_date)
      end

    end

  end
end
