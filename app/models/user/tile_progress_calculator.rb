class User
  class TileProgressCalculator
    attr_reader :available, :completed, :available_ids, :completed_ids, :tiles_not_used_in_tile_progress
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

    private


    def set_vars
      @available =  @user.demo.tiles.where(status: Tile::ACTIVE).all
      @completed = @user.completed_tiles.where(demo_id: @user.demo, status: Tile::ACTIVE).all
      @available_ids = @available.map(&:id)
      @completed_ids = @completed.map(&:id)
      @tiles_not_used_in_tile_progress = tiles_not_used(@user.id, @user.demo.id).all
    end

    def tiles_not_used user_id, demo_id
      Tile.joins(:tile_completions).
        where do 
        (status == Tile::ACTIVE) & 
          (tile_completions.user_id == user_id) & 
          (tile_completions.not_show_in_tile_progress == true) & 
          (demo_id == demo_id) 
      end
    end

    def available_differs_from_completed?
      available_ids.sort != completed_ids.sort
    end


  end
end
