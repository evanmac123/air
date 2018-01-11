class User
  class TileProgressCalculator
    attr_reader :user, :available, :completed, :available_ids, :completed_ids, :tiles_not_used_in_tile_progress
    def initialize(user)
      @user = user
      set_vars
    end


    def available_tiles_on_current_demo
      available_differs_from_completed?
      if available_differs_from_completed?
        @available -= tiles_not_used_in_tile_progress
      end
      @available
    end

    def completed_tiles_on_current_demo
      if available_differs_from_completed?
        @completed -= tiles_not_used_in_tile_progress
      end
      @completed
    end


    def not_show_all_completed_tiles_in_progress
      completed_tiles = user.tile_completions.joins(:tile).where(tiles: { demo_id: user.demo_id, status: Tile::ACTIVE }, not_show_in_tile_progress: false)

      completed_tiles.update_all(not_show_in_tile_progress: true)
    end

    private

      def set_vars
        @available =  user.demo.tiles.where(status: Tile::ACTIVE)
        @completed = user.completed_tiles.where(demo_id: user.demo, status: Tile::ACTIVE)
        @available_ids = @available.map(&:id)
        @completed_ids = @completed.map(&:id)
        @tiles_not_used_in_tile_progress = tiles_not_used(user.id, user.demo.id)
      end

      def tiles_not_used user_id, demo_id
        user.demo.tiles.active.joins(:tile_completions).where(tile_completions: { user_id: user.id, not_show_in_tile_progress: true })
      end

      def available_differs_from_completed?
        available_ids.sort != completed_ids.sort
      end
  end
end
