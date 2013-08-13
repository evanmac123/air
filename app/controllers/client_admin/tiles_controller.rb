class ClientAdmin::TilesController < ClientAdminBaseController
  before_filter :get_demo

  def index
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at  # Demo attributes
    @tile_digest_email_send_on = @demo.tile_digest_email_send_on  # (i.e. not the usual finder methods)

    @demo.archive_tiles_if_expired

    @active_tiles  = @demo.active_tiles
    @archive_tiles = @demo.archive_tiles
    @digest_tiles  = @demo.digest_tiles
  end

  def new
    @tile_builder_form = TileBuilderForm.new(@demo)
  end

  def create
    @tile_builder_form = TileBuilderForm.new(@demo, parameters: params[:tile_builder_form])

    if @tile_builder_form.create_objects
      set_after_save_flash(@tile_builder_form.tile)
      redirect_to client_admin_tile_path(@tile_builder_form.tile)
    else
      flash[:failure] = "Sorry, we couldn't save this tile: " + @tile_builder_form.error_messages
      render "new"
    end
  end

  def update
    @tile = get_tile

    if params[:update_status]
      update_status
      redirect_to action: :index
    else
      update_fields
    end
  end

  def show
    @tile = get_tile
    @client_created_tiles = {@tile => @tile.appears_client_created}
  end

  def edit
    @tile_builder_form = TileBuilderForm.new(@demo, tile: Tile.find(params[:id]))
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
      success = 'activated'
      failure = 'activating'
    end
    [success, failure]
  end

  def update_status
    success, failure = flash_status_messages

    update_timestamp = case params[:update_status]
      when Tile::ACTIVE  then {activated_at: Time.now}
      when Tile::ARCHIVE then {archived_at:  Time.now}
      else {}
    end

# todo define attribute setter that updates times along with status

    if @tile.update_attributes( {status: params[:update_status]}.merge(update_timestamp) )
      flash[:success] = "The #{@tile.headline} tile has been #{success}"
    else
      flash[:failure] = "There was a problem #{failure} this tile. Please try again."
    end
  end

  def update_fields
    @tile_builder_form = TileBuilderForm.new(@demo, parameters: params[:tile_builder_form], tile: @tile)

    if @tile_builder_form.update_objects
      set_after_save_flash(@tile_builder_form.tile)
      redirect_to client_admin_tile_path(@tile_builder_form.tile)
    else
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
end
