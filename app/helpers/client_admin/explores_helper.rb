module ClientAdmin::ExploresHelper

  def show_tile_likes(tile)
    tile.like_count
  end
  
  def show_my_liked_tile(tile)    
    if tile.like_count == 1
      "You liked this tile"      
    else
      "You and #{pluralize(tile.like_count - 1, 'other')}"
    end
  end
  
  def show_unliked_tile(tile)
    if tile.like_count < 1
      "Be the first person to like this tile"
    elsif tile.like_count == 1
      "#{tile.user_tile_likes.last.user.name} liked this tile"
    else
      "#{tile.user_tile_likes.last.user.name} and #{pluralize(tile.like_count - 1, 'other')}"
    end    
  end
  
  def show_my_copied_tile(tile)
    unique_copy_count = tile.unique_user_copy_count
    if unique_copy_count == 1
      "You copied this tile"      
    else
      "You and #{pluralize(unique_copy_count - 1, 'other')}"
    end    
  end
  
  def show_uncopied_tile(tile)
    unique_copy_count = tile.unique_user_copy_count
    if unique_copy_count < 1
      "Be the first person to copy this tile"
    elsif unique_copy_count == 1
      "#{tile.user_tile_copies.last.user.name} copied this tile"
    else
      "#{tile.user_tile_copies.last.user.name} and #{pluralize(unique_copy_count - 1, 'other')}"
    end        
  end
  
  def show_author_info(tile)
    author_name = []
    author_name << tile.creator.name if tile.creator
    author_name << tile.demo.client_name if tile.demo.client_name.present?
    author_name << tile.demo.name
    
    author_name.join(', ')
  end
end
