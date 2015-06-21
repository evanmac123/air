class SuggestedTilesController < ApplicationController
  def new
    get_tile_images
    @tile_builder_form = UserTileBuilderForm.new(current_user.demo)
  end

  def index
    @creation_placeholder = [TileCreationPlaceholder.new(new_suggested_tile_path)]
    @submitted_tiles = Demo.add_placeholders current_user.tiles.user_submitted
    @posted_tiles = Demo.add_placeholders current_user.tiles.active
    @archived_tiles = Demo.add_placeholders current_user.tiles.archived

    user_action_ping "Suggestion Box Opened"
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
      user_action_ping "Tile Created"
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

  def user_action_ping action
    ping('Suggestion Box', {user_action: action}, current_user)
  end
end
