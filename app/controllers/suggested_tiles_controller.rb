class SuggestedTilesController < ApplicationController
  def new
    @tile_images = TileImage.all_ready.first(TileImage::PAGINATION_PADDING)
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
      flash[:success] = "TK: We should have some real copy here."
      redirect_to suggested_tiles_path
    else
      flash.now[:failure] = @tile_builder_form.error_message
      render "new"
    end
  end
end
