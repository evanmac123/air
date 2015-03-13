class ClientAdmin::TilesController < ClientAdminBaseController
  include ClientAdmin::TilesHelper
  include ClientAdmin::TilesPingsHelper
  
  before_filter :get_demo
  before_filter :load_tags, only: [:new, :edit, :create, :update]
  before_filter :load_image_library, only: [:new, :edit, :create, :update]

  def index
    # Update 'status' for tiles with 'start_time' and 'end_time' attributes (before you fetch the different tile groups)
    @demo.activate_tiles_if_showtime
    @demo.archive_tiles_if_curtain_call
    @active_tiles  = @demo.active_tiles_with_placeholders
    @archive_tiles = (@demo.archive_tiles_with_placeholders)[0,4]
    @draft_tiles = (@demo.draft_tiles_with_placeholders)[0,8]
    @show_more_draft_tiles = show_more_draft_tiles
    @board_is_brand_new = @demo.tiles.limit(1).first.nil?
    record_index_ping
  end
  
  def new    
    @tile_builder_form = TileBuilderForm.new(@demo)
    record_new_ping
  end

  def create
    @tile_builder_form =  TileBuilderForm.new(
                            @demo,
                            parameters: params[:tile_builder_form],
                            creator: current_user
                          )
    if @tile_builder_form.create_tile
      set_after_save_flash(@tile_builder_form.tile)
      schedule_tile_creation_ping(@tile_builder_form.tile)
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
      record_update_status_ping
    else
      update_fields        
    end
  end

  def show
    @tile = get_tile
    return show_partial if params[:partial_only]

    if !current_user.share_section_intro_seen
      @show_share_section_intro = true
      current_user.share_section_intro_seen = true
      current_user.save!
    end
    set_tiles_path_tag
  end

  def edit
    tile = get_tile
    @tile_builder_form = tile.to_form_builder
    record_edit_ping
  end

  def destroy
    @tile = get_tile
    flash[:success] = "You've successfully deleted the #{@tile.headline} Tile."
    @tile.destroy
    destroy_tile_ping params[:page]
    redirect_to client_admin_tiles_path
  end

  def sort
    @tile = get_tile
    Tile.insert_tile_between(
      params[:left_tile_id], 
      @tile.id, 
      params[:right_tile_id], 
      params[:status]
    )
    @tile.reload

    @last_tiles = []
    if params[:source_section].present?
      @last_tiles = Tile.find_additional_tiles_for_manage_section(
                      params[:source_section][:name],
                      params[:source_section][:presented_ids],
                      get_demo.id
                    )
    end

    @show_more_draft_tiles = show_more_draft_tiles

    tile_status_updated_ping @tile, "Dragged tile to move"
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
    is_new = @tile.activated_at.nil?
    if @tile.update_status(params[:update_status])
      flash[:success] = "The #{@tile.headline} tile has been #{success}"
      tile_status_updated_ping @tile, "Clicked button to move"
    else
      flash[:failure] = "There was a problem #{failure} this tile. Please try again."
    end

    redirect_to :back
  end
  
  def update_fields
    @tile_builder_form =  TileBuilderForm.new( 
                            @demo,
                            parameters: params[:tile_builder_form],
                            tile: @tile
                          )
    if @tile_builder_form.update_tile
      set_after_save_flash(@tile_builder_form.tile)
      redirect_to client_admin_tile_path(@tile_builder_form.tile)
    else
      flash[:failure] = "Sorry, we couldn't update this tile: " + @tile_builder_form.error_messages
      set_flash_for_no_image
      render :edit
    end
  end

  def show_partial
    @tile = Tile.next_manage_tile(@tile, params[:offset].to_i)
    render json: {
      tile_id:      @tile.id,
      tile_content: render_to_string("client_admin/tiles/show", :layout => false)
    }
  end

  def set_after_save_flash(new_tile)
    activate_url = client_admin_tile_path(new_tile, update_status: Tile::ACTIVE)
    edit_url = edit_client_admin_tile_path(new_tile)
    already_active = new_tile.active?

    flash[:success] = render_to_string("preview_after_save_flash", 
      layout: false, locals: {
        action: params[:action], 
        edit_url: edit_url, 
        activate_url: activate_url, 
        already_active: already_active
      }
    )
    flash[:success_allow_raw] = true
  end

  def set_flash_for_no_image
    if @tile_builder_form.no_image
      flash[:failure] = render_to_string("save_tile_without_an_image", layout: false, locals: { tile: @tile_builder_form.tile })
      flash[:failure_allow_raw] = true
    end
  end

  def set_tiles_path_tag
    @tag = if @tile.active?
             :via_posted_preview
           elsif @tile.archived?
             :via_archived_preview
           else
             :via_draft_preview
           end
  end

  def show_more_draft_tiles
    @demo.draft_tiles.count > 7
  end

  def load_image_library
    @tile_images = TileImage.
      where(image_processing: false, thumbnail_processing: false).
      order{ created_at.desc }
  end
end
