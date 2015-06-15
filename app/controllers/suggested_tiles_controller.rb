class SuggestedTilesController < ApplicationController
  def new
    get_tile_images
    @tile_builder_form = UserTileBuilderForm.new(current_user.demo)
  end

  def index
    @creation_placeholder = [TileCreationPlaceholder.new(new_suggested_tile_path)]
    @submitted_tiles = current_user.tiles.user_submitted
    @accepted_tiles = current_user.tiles.draft
    @posted_tiles = current_user.tiles.active
    @archived_tiles = current_user.tiles.archived
  end

  def show
    get_tile
  end

  def create
    @tile_builder_form =  UserTileBuilderForm.new(
                            current_user.demo,
                            parameters: params[:tile_builder_form],
                            creator: current_user
                          )
    
    if @tile_builder_form.create_tile
      set_success_flash
      redirect_to suggested_tile_path(@tile_builder_form.tile)
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

  def get_tile
    @tile = current_user.tiles.find(params[:id])
  end

  def set_success_flash
    flash[:success] = "The administrator has been notified that you've submitted a Tile to the Suggestion Box. You'll be notified if your Tile is accepted." 
  end
end
