module TilePreviewsHelper
  def show_tile_copies(tile, current_user)
    unique_copy_count = tile.unique_user_copy_count
    
    if unique_copy_count < 1
      "Be the first person to copy this tile"
    elsif unique_copy_count < 2
      if current_user.copied_tile?(tile)
        "Copied by you"
      else
        "Copied by #{tile.user_tile_copies.last.user.name}"
      end
    elsif unique_copy_count == 2
      unique_tile_copies = tile.user_tile_copies.
        select('user_id, tile_id, max(id) id').
        group('user_id, tile_id').order('max(id) DESC')
      
      if current_user.copied_tile?(tile)
        "Copied by you and #{unique_tile_copies.limit(1)[0].user.name}"
      else
        user_tile_copies = unique_tile_copies.limit(2)
        "Copied by #{user_tile_copies[0].user.name} and #{user_tile_copies[1].user.name}"
      end
    else #count is greater than 3
      unique_tile_copies = tile.user_tile_copies.select('user_id, tile_id').where("user_id != ?", current_user.id).order('user_id DESC').uniq

      if current_user.copied_tile?(tile)
        "Copied by you, #{unique_tile_copies.limit(1)[0].user.name}, and #{pluralize(unique_copy_count - 2, 'other')}"
      else
        user_tile_copies = unique_tile_copies.limit(2)
        "Copied by #{user_tile_copies[0].user.name}, #{user_tile_copies[1].user.name}, and #{pluralize(unique_copy_count - 2, 'other')}"
      end
    end
  end

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
end
