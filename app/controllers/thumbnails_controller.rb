class ThumbnailsController < ApplicationController
  THUMBNAIL_POLL_DELAY = 5

  def index
    tiles = current_user.demo.tiles

    if params[:tile_ids]
      tiles = tiles.where(id: params[:tile_ids].split(","))
    end

    tile_json = tiles.map{|tile| {id: tile.id, stillProcessing: tile.thumbnail_really_still_processing, imageURL: tile.thumbnail.url, type: 'thumbnail'}}.to_json
    render inline: tile_json
  end
end
