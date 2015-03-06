class ThumbnailsController < ApplicationController
  THUMBNAIL_POLL_DELAY = 5

  def index
    response =  if params[:tile_ids].present?
                  tile_json
                elsif params[:tile_image_ids].present?
                  tile_image_json
                else
                  nil
                end

    render inline: response
  end

  protected

  def tile_json
    tile_ids = params[:tile_ids].try(:split, ",")
    tiles = current_user.demo.tiles.where(id: tile_ids)
    tiles.map{|tile| {
        id: tile.id, 
        stillProcessing: tile.thumbnail_really_still_processing, 
        imageURL: tile.thumbnail.url, 
        type: 'thumbnail'
      }
    }.to_json
  end

  def tile_image_json
    tile_image_ids = params[:tile_image_ids].try(:split, ",")
    tile_images = TileImage.where(id: tile_image_ids)
    tile_images.map{|ti| {
        id: ti.id, 
        stillProcessing: ti.thumbnail_really_still_processing, 
        imageURL: ti.thumbnail.url, 
        type: 'tileImageThumbnail'
      }
    }.to_json
  end
end
