class TileInteractionFactory
  attr_reader :tile

  def self.get context, tile, user, is_preview
    completion = user.tile_completions.where(tile_id: tile.id).first

    clazz =  if is_preview
               PreviewInteraction
             elsif completion 
               UserCompletedInteraction
             else
               UserCompletableInteraction
             end
    clazz.new tile, context, user, completion
  end

end
