class ClientAdmin::TilesController < ClientAdminBaseController
  before_filter :get_demo

  def index
    # Update 'status' for tiles with 'start_time' and 'end_time' attributes (before you fetch the different tile groups)
    @demo.activate_tiles_if_showtime
    @demo.archive_tiles_if_curtain_call
    @active_tiles  = @demo.active_tiles_with_placeholders
    @archive_tiles = (@demo.archive_tiles_with_placeholders)[0,8]
    @draft_tiles = (@demo.draft_tiles_with_placeholders)[0,8]
    
    @tile_just_activated = flash[:tile_activated] || false
  end

  def new
    @tile_builder_form = TileBuilderForm::MultipleChoice.new(@demo)
  end

  def create
    @tile_builder_form = TileBuilderForm::MultipleChoice.new(@demo, \
                            parameters: params[:tile_builder_form], \
                            creator: current_user, \
                            image_container: params[:image_container])
    if @tile_builder_form.create_objects
      set_after_save_flash(@tile_builder_form.tile)
      schedule_tile_creation_ping
      redirect_to client_admin_tile_path(@tile_builder_form.tile)
    else
      make_image_container
      flash[:failure] = "Sorry, we couldn't save this tile: " + @tile_builder_form.error_messages
      render "new"
    end
  end

  def update
    @tile = get_tile
    
    if params[:update_status]
      update_status
    else
      update_fields
    end
  end

  def show
    @tile = get_tile
    @tile_just_activated = flash[:tile_activated] || false
    if @tile.draft?
      @show_tile_post_guide = !current_user.displayed_tile_post_guide? && @tile.demo.non_activated?
      current_user.displayed_tile_post_guide = true
      current_user.save!
    elsif @tile_just_activated
      @show_tile_success_guide = !current_user.displayed_tile_success_guide? && @tile.demo.tiles.active.count == 1
      current_user.displayed_tile_success_guide = true
      current_user.save!
    end    
  end

  def edit
    tile = get_tile
    @tile_builder_form = tile.to_form_builder
  end
  
  def active_tile_guide_displayed
    current_user.displayed_active_tile_guide=true
    current_user.save!
    render nothing: true
  end

  private

  def get_demo
    @demo = current_user.demo
  end

  def get_tile
    current_user.demo.tiles.find params[:id]
  end

  def flash_status_messages
    if params[:update_status] == Tile::ARCHIVE
      success = 'archived'
      failure = 'archiving'
    else
      success = 'published'
      failure = 'publishing'
    end
    [success, failure]
  end

  def update_status
    success, failure = flash_status_messages

    if @tile.update_attributes status: params[:update_status]
      flash[:tile_activated] = @tile.active?
      flash[:success] = "The #{@tile.headline} tile has been #{success}"
    else
      flash[:failure] = "There was a problem #{failure} this tile. Please try again."
    end

    redirect_to :back
  end

  def update_fields
    @tile_builder_form = @tile.form_builder_class.new(@demo, \
                      parameters: params[:tile_builder_form], \
                      tile: @tile, \
                      image_container: params[:image_container])

    if @tile_builder_form.update_objects
      set_after_save_flash(@tile_builder_form.tile)
      redirect_to client_admin_tile_path(@tile_builder_form.tile)
    else
      make_image_container
      flash[:failure] = "Sorry, we couldn't update this tile: " + @tile_builder_form.error_messages
      render :edit
    end
  end

  def set_after_save_flash(new_tile)
    activate_url = client_admin_tile_path(new_tile, update_status: Tile::ACTIVE)
    edit_url = edit_client_admin_tile_path(new_tile)
    already_active = new_tile.active?

    flash[:success] = render_to_string("preview_after_save_flash", layout: false, locals: {edit_url: edit_url, activate_url: activate_url, already_active: already_active})
    flash[:success_allow_raw] = true
  end

  def schedule_tile_creation_ping
    ping('Tile - New', {}, current_user)
  end

  def make_image_container
    @container = if params["image_container"]
      ImageContainer.find(params["image_container"]) 
    else
      ImageContainer.tile_image(params[:tile_builder_form][:image]) 
    end
  end
end
