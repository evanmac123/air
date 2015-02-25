module UserInParentBoard
  def current_user
    parent_board_user || super
  end

  def parent_board_user
    @parent_board_user
  end

  def set_parent_board_user(board_id)
    if current_user.have_access_to_parent_board?(board_id) && 
       board_id.to_i != current_user.demo_id
      
      @parent_board_user = ParentBoardUser.where(demo_id: board_id, user: current_user).first
      unless @parent_board_user
        @parent_board_user = ParentBoardUser.create!(demo_id: board_id, user: current_user)
      end
    end
  end

  def set_parent_board_user_by_tile(tile_id)
    tile = Tile.where(id: tile_id).first
    set_parent_board_user(tile.demo_id) if tile
  end
end