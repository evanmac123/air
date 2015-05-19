class SuggestedTilesController < ApplicationController
  def new
    get_tile_images
    @tile_builder_form = UserTileBuilderForm.new(current_user.demo)
  end

  def index
    @draft_tiles = [TileCreationPlaceholder.new(new_suggested_tile_path)] + current_user.tiles.user_draft
  end

  def create
    @tile_builder_form =  UserTileBuilderForm.new(
                            current_user.demo,
                            parameters: params[:tile_builder_form],
                            creator: current_user
                          )
    
    if @tile_builder_form.create_tile
      flash[:success] = "Tile created! We're resizing the graphics, which usually takes less than a minute."
      redirect_to suggested_tiles_path
    else
      flash.now[:failure] = @tile_builder_form.error_message
      get_tile_images
      render "new"
    end
  end

  private

  def get_tile_images
    @tile_images = TileImage.all_ready.first(TileImage::PAGINATION_PADDING)
  end
end
