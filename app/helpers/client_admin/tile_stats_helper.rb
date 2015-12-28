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

  def thumb_menu(presenter)
    render(partial: 'client_admin/tiles/manage_tiles/tile_thumbnail_menu', locals: {presenter: presenter})
  end
end
