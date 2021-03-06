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
    when 'free_response'
      "There is no free reponse activity for this Tile."
    else
      ""
    end
  end



  def is_free_response_answer? tile, row
    tile.question_subtype == "free_response" || tile.allow_free_response && row.free_response != ""
  end

end
