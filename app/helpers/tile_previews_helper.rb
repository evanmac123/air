module TilePreviewsHelper
  def show_tile_copies(tile, current_user)
    unique_copy_count = tile.unique_user_copy_count
    
    if unique_copy_count < 1
      "Be the first person to copy this tile"
    elsif unique_copy_count < 2
      if current_user.copied_tile?(tile)
        "You copied this tile"
      else
        "#{tile.user_tile_copies.last.user.name} copied this tile"
      end
    elsif unique_copy_count == 2
      unique_tile_copies = tile.user_tile_copies.select('DISTINCT user_id, tile_id').where('user_id <> ?', current_user.id)
      if current_user.copied_tile?(tile)
        "You and #{unique_tile_copies.last.user.name} have copied this tile"
      else
        user_tile_copies = unique_tile_copies.limit(2).order('created_at DESC')
        "#{user_tile_copies[0].user.name} and #{user_tile_copies[1].user.name} have copied this tile"
      end
    else #count is greater than 3
      unique_tile_copies = tile.user_tile_copies.select('DISTINCT user_id, tile_id').where('user_id <> ?', current_user.id).limit(2)
      if current_user.copied_tile?(tile)
          "You, #{unique_tile_copies.last.user.name} and #{pluralize(unique_copy_count - 2, 'other')}"        
      else
        user_tile_copies = unique_tile_copies.order('created_at DESC')       
        "#{user_tile_copies[0].user.name}, #{user_tile_copies[1].user.name} and #{pluralize(unique_copy_count - 2, 'other')}"
      end
    end
  end

  def show_tile_likes(tile, current_user)
    if tile.like_count < 1
      "Be the first person to like this tile"
    elsif tile.like_count < 2
      if current_user.likes_tile?(tile)
        "You liked this tile"
      else
        "#{tile.user_tile_likes.last.user.name} liked this tile"
      end
    elsif tile.like_count < 2
      if current_user.likes_tile?(tile)
        "You and #{tile.user_tile_likes.where('user_id <> ?', current_user.id).last.
        user.name} have liked this tile"
      else
        user_tile_likes = tile.user_tile_likes.limit(2).order('created_at DESC')       
        "#{user_tile_likes[0].user.name} and #{user_tile_likes[1].user.name} have liked this tile"
      end
    else #count is greater than 3
      if current_user.likes_tile?(tile)
        "You, #{tile.user_tile_likes.where('user_id <> ?', current_user.id).last.
        user.name} and #{pluralize(tile.like_count - 1, 'other')}"
      else
        user_tile_likes = tile.user_tile_likes.limit(2).order('created_at DESC')       
        "#{user_tile_likes[0].user.name}, #{user_tile_likes[1].user.name} and #{pluralize(tile.like_count - 1, 'other')}"
      end
    end
  end
end