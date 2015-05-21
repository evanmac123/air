class SuggestedTilesController < ApplicationController
  ALLOWED_STATES = [Tile::USER_SUBMITTED, Tile::USER_DRAFT].freeze

  def new
    get_tile_images
    @tile_builder_form = UserTileBuilderForm.new(current_user.demo)
  end

  def index
    @draft_tiles = [TileCreationPlaceholder.new(new_suggested_tile_path)] + current_user.tiles.user_draft
    @submitted_tiles = current_user.tiles.user_submitted
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
      flash[:success] = "Tile created! We're resizing the graphics, which usually takes less than a minute."
      #redirect_to suggested_tile_path(@tile_builder_form.tile)
      redirect_to suggested_tile_path(@tile_builder_form.tile)
    else
      flash.now[:failure] = @tile_builder_form.error_message
      get_tile_images
      render "new"
    end
  end

  def update
    get_tile
    new_status = params[:update_status]
    if can_update_to_status?(new_status)
      @tile.status = new_status
      @tile.save!
      set_success_flash(new_status)
    end

    redirect_to :back
  end

  private

  def get_tile_images
    @tile_images = TileImage.all_ready.first(TileImage::PAGINATION_PADDING)
  end

  def get_tile
    @tile = current_user.tiles.find(params[:id])
  end

  def can_update_to_status?(status)
    ALLOWED_STATES.include? status
  end

  def set_success_flash(new_status)
    flash[:success]= case new_status
                     when Tile::USER_SUBMITTED
                       "TK: you submitted a tile"    
                     when Tile::USER_DRAFT
                       "TK: you unsubmitted a tile"    
                     end
  end
end
