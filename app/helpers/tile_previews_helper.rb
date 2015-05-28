module TilePreviewsHelper
  def get_tile_likes(tile, current_user)
    tile.like_count
  end

  def show_tile_likes(tile, current_user)
    if tile.like_count < 1
      "Be the first person to like this tile"
    elsif tile.like_count < 2
      if current_user.likes_tile?(tile)
        "Liked by you"
      else
        "Liked by #{tile.user_tile_likes.last.user.name}"
      end
    elsif tile.like_count == 2
      if current_user.likes_tile?(tile)
        "Liked by you and #{tile.user_tile_likes.where('user_id <> ?', current_user.id).last.
        user.name}"
      else
        user_tile_likes = tile.user_tile_likes.limit(2).order('created_at DESC')       
        "Liked by #{user_tile_likes[0].user.name} and #{user_tile_likes[1].user.name}"
      end
    else #count is greater than 3
      if current_user.likes_tile?(tile)
        "Liked by you, #{tile.user_tile_likes.where('user_id <> ?', current_user.id).last.
        user.name}, and #{pluralize(tile.like_count - 2, 'other')}"
      else
        user_tile_likes = tile.user_tile_likes.limit(2).order('created_at DESC')       
        "Liked by #{user_tile_likes[0].user.name}, #{user_tile_likes[1].user.name}, and #{pluralize(tile.like_count - 2, 'other')}"
      end
    end
  end
  
  def show_company_and_demo(tile)
    author_name = []
    
    #author_name << tile.creator.name if tile.creator
    author_name << tile.demo.client_name if tile.demo.client_name.present?
    author_name << tile.demo.name
    
    author_name.join(', ')
  end
  
  def share_tile_link tile
    request.host_with_port.gsub(/^www./, "") + explore_tile_preview_path(tile)
  end

  def sharable_tile_link tile
    request.host_with_port.gsub(/^www./, "") + sharable_tile_path(tile)
  end
end
