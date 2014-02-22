class CopyTilesController < ApplicationController
  skip_before_filter :authorize

  def create
    tile = Tile.copyable.where(id: params[:tile_id]).first
    tile.copy_to_new_demo(current_user.demo)
    render inline: 'hey'
  end
end
