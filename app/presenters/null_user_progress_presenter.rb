class NullUserProgressPresenter 
  def initialize(user_id, demo, tile_value)
    @user_id = user_id
    @demo_id = demo.id
    @available_tile_count = demo.tiles.active.count
    @completed_tile_count = nil 
    @points =0
    @tile_points = tile_value;
  end
 
  attr_reader :available_tile_count, :completed_tile_count, :points, :tile_points

  def some_tiles_undone?
    true  
  end

  def old_browser?
    false
  end
 
  def persist_locally?
    true
  end 

  def storage_key
    "progress.#{@demo_id}.#{@user_id}"
  end

  def config
    {user: @user_id, demo: @demo_id, available: available_tile_count, completed: completed_tile_count, points: 0, tile_points: tile_points, key:storage_key}.to_json
   
  end

end
