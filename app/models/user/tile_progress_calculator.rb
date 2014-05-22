class User
  class TileProgressCalculator
    def initialize(user)
      @user = user
    end

    def available_tiles_on_current_demo
      available = @user.demo.tiles.where(status: Tile::ACTIVE)
      completed = @user.completed_tiles.where(demo_id: @user.demo, status: Tile::ACTIVE)
      if available.pluck(:id).sort != completed.pluck(:id).sort
        available -= tiles_not_used_in_tile_progress
      end
      available
    end

    def completed_tiles_on_current_demo
      available = @user.demo.tiles.where(status: Tile::ACTIVE)
      completed = @user.completed_tiles.where(demo_id: @user.demo, status: Tile::ACTIVE)
      if available.pluck(:id).sort != completed.pluck(:id).sort
        completed -= tiles_not_used_in_tile_progress
      end
      completed
    end

    def tiles_not_used_in_tile_progress
      userid = @user.id
      tile_demo_id = @user.demo_id
      Tile.joins(:tile_completions).
        where do 
          (status == Tile::ACTIVE) & 
          (tile_completions.user_id == userid) & 
          (tile_completions.not_show_in_tile_progress == true) & 
          (demo_id == tile_demo_id) 
        end
    end

    def not_show_all_completed_tiles_in_progress
      userid = @user.id
      tile_demo_id = @user.demo_id
      completed_tiles = TileCompletion.joins(:tile).
        where do 
          (tile.status == Tile::ACTIVE) & 
          (user_id == userid) & 
          (not_show_in_tile_progress == false) & 
          (tile.demo_id == tile_demo_id) 
        end
      completed_tiles.update_all(not_show_in_tile_progress: true)
    end
  end
end