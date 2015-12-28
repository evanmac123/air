module ClientAdmin::TileStatsHelper
  def empty_grid_message grid_type
    case grid_type
    when 'live'
      "No users have viewed or interacted with Tiles."
    when 'viewed_and_interacted'
      "No users have viewed or interacted with Tiles."
    when 'viewed_only'
      "No users have only viewed Tiles."
    when 'not_viewed'
      "All users have viewed at least one Tile."
    else
      ""
    end
  end
end
