# frozen_string_literal: true

class User
  class TileProgressCalculator
    attr_reader :user, :differs_from_completed

    def initialize(user)
      @user = user
      @active_tiles = @user.segmented_tiles_for_user
      @completed_tiles = @user.completed_tiles_in_demo.where(status: Tile::ACTIVE)
      @differs_from_completed = available_differs_from_completed?
    end

    def available_tiles_for_points_progress
      if differs_from_completed
        active_tiles.where.not(id: tiles_not_used)
      else
        active_tiles
      end
    end

    def completed_tiles_for_points_progress
      if differs_from_completed
        completed_tiles.where.not(id: tiles_not_used)
      else
        completed_tiles
      end
    end

    def not_show_all_completed_tiles_in_progress
      completed_tiles = user.tile_completions.joins(:tile).where(tiles: { id: completed_tiles_for_points_progress })

      completed_tiles.update_all(not_show_in_tile_progress: true)
    end

    private
      attr_reader :active_tiles, :completed_tiles

      def tiles_not_used
        active_tiles.joins(:tile_completions).where(tile_completions: { user_id: user.id, not_show_in_tile_progress: true })
      end

      def available_differs_from_completed?
        active_tiles.order(:id) != completed_tiles.order(:id)
      end
  end
end
