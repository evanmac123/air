module ClientAdmin::ExploresHelper

  def show_tile_likes(tile)
    tile.like_count
  end
  
  def show_author_info(tile)
    author_name = []
    author_name << tile.creator.name if tile.creator
    author_name << tile.demo.client_name if tile.demo.client_name.present?
    author_name << tile.demo.name
    
    author_name.join(', ')
  end
end
