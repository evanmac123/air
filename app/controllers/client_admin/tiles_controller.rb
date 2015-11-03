class ClientAdmin::TilesController < ClientAdminBaseController
  include ClientAdmin::TilesHelper
  include ClientAdmin::TilesPingsHelper

  before_filter :get_demo
  before_filter :load_tags, only: [:new, :edit, :update]

  def index
    # Update 'status' for tiles with 'start_time' and 'end_time' attributes (before you fetch the different tile groups)
    @demo.activate_tiles_if_showtime
    @demo.archive_tiles_if_curtain_call
    @active_tiles  = @demo.active_tiles_with_placeholders
    @archive_tiles = (@demo.archive_tiles_with_placeholders)[0,4]
    @draft_tiles = @demo.draft_tiles_with_placeholders
    @suggested_tiles = @demo.suggested_tiles_with_placeholders
    @user_submitted_tiles_counter = @demo.tiles.user_submitted.count

    @allowed_to_suggest_users = @demo.users_that_allowed_to_suggest_tiles

    intro_flags_index

    @accepted_tile = Tile.find(session.delete(:accepted_tile_id)) if session[:accepted_tile_id]

    record_index_ping
  end

  def new
    @tile_builder_form = TileBuilderForm.new(@demo, builder_options)
    record_new_ping

    if request.xhr?
      render partial: "shared/tiles/builder", layout: false and return
    else
      load_image_library
      #normal rails render
    end

  end


  def edit
    tile = get_tile
    load_image_library
    record_edit_ping
    @tile_builder_form = TileBuilderForm.new(@demo,builder_options.merge(tile: tile))

    if request.xhr?
      render layout: false and return
    else
      #normal rails render
    end

  end

  #TODO consider refactoring with custom responders
  def create
    @tile_builder_form =  TileBuilderForm.new(@demo,builder_options)
    if @tile_builder_form.create_tile
      set_after_save_flash(@tile_builder_form.tile)
      schedule_tile_creation_ping(@tile_builder_form.tile)
      if request.xhr?
        @tile = @tile_builder_form.tile
        render_preview_and_single
      else
        redirect_to client_admin_tile_path(@tile_builder_form.tile)
      end
    else
      if request.xhr?
        response.headers["X-Message"]= @tile_builder_form.error_message
        head :unprocessable_entity and return
      else
        flash.now[:failure] = @tile_builder_form.error_message
        load_tags
        load_image_library
        render "new"
      end
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
    prepTilePreview
    tile_in_box_viewed_ping @tile
    if request.xhr?
      render layout: false
    end
  end

  def blank
    render "blank", layout: "empty_layout"
  end

  def destroy
    @tile = get_tile
    flash[:success] = "You've successfully deleted the #{@tile.headline} Tile."
    @tile.destroy
    destroy_tile_ping params[:page]
    redirect_to client_admin_tiles_path
  end

  def sort
 #FIXME this code sucks!!! simply posting of tile ids and current positions
    #would simplify this whole process
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


    #FIXME is this really important for tracking?
    tile_status_updated_ping @tile, "Dragged tile to move"

  end

  #FIXME should refactor and cosolidate the existing update method but the functionality is too
  #convoluted to fix now.

  def status_change
    @tile = get_tile

    @tile.update_status(params[:update_status])
    presenter = SingleTilePresenter.new(@tile, :html, @is_client_admin_action, browser.ie?)
    render partial: 'client_admin/tiles/manage_tiles/single_tile', locals: { presenter: presenter}
  end

  def update_explore_settings
    tpf = TilePublicForm.new(get_tile, params[:tile_public_form])
    tpf.save
    @tile = tpf.tile
    render_preview_and_single
  end

  private

  def prepTilePreview
    @prev, @next = @demo.bracket @tile
    @show_share_section_intro = show_share_section_intro
  end


  def intro_flags_index
    @board_is_brand_new = @demo.tiles.limit(1).first.nil? && params[:show_suggestion_box] != "true"
    @show_suggestion_box_intro =  if !current_user.suggestion_box_intro_seen

                                    current_user.suggestion_box_intro_seen = true
                                    current_user.save
                                  end
    @user_submitted_tile_intro =  if  params[:user_submitted_tile_intro] &&
                                      !current_user.user_submitted_tile_intro_seen &&
                                      @demo.tiles.user_submitted.first.present? &&
                                      !@show_suggestion_box_intro

                                    current_user.user_submitted_tile_intro_seen = true
                                    current_user.save
                                  end
    @manage_access_prompt = !current_user.manage_access_prompt_seen &&
      if @user_submitted_tiles_counter > 0 ||
         @allowed_to_suggest_users.count > 0 ||
         @demo.everyone_can_make_tile_suggestions

        current_user.manage_access_prompt_seen = true
        current_user.save
        false
      else
        true
      end
  end

  def show_share_section_intro
    if !current_user.share_section_intro_seen && @tile.has_client_admin_status?
      current_user.share_section_intro_seen = true
      current_user.save!
      true
    end
  end

  def get_demo
    @demo = current_user.demo
  end

  def get_tile
    tile = current_user.demo.tiles.find params[:id]
    if params[:offset].present?
      tile = Tile.next_manage_tile(tile, params[:offset].to_i)
    end

    tile
  end

  def flash_status_messages
    success, failure = case params[:update_status]
    when Tile::ARCHIVE
      ['archived', 'archiving']
    when Tile::ACTIVE
      ['published', 'publishing']
    when Tile::USER_SUBMITTED
      ['moved to submitted', 'with moving to submitted']
    when Tile::IGNORED
      ['ignored', 'ignoring']
    when Tile::DRAFT
      ['accepted', 'accepting']
    else
      ['', '']
    end
    [success, failure]
  end

  def update_status
    result = @tile.update_status(params[:update_status])
    respond_to do |format|
      format.js { update_status_js(result) }
      format.html { update_status_html(result) }
    end
  end




  def update_status_html result
    success, failure = flash_status_messages
    #is_new = @tile.activated_at.nil?
    if result
      tile_status_updated_ping @tile, "Clicked button to move"
      if @tile.draft?
        session[:accepted_tile_id] = @tile.id
        redirect_to client_admin_tiles_path
      else
        flash[:success] = "The #{@tile.headline} tile has been #{success}"
        redirect_to :back
      end
    else
      flash[:failure] = "There was a problem #{failure} this tile. Please try again."
      redirect_to :back
    end
  end

  def update_status_js result
    if result
      tile_in_box_updated_ping @tile

      render json: {
        success: true,
        tile: render_tile_string,
        tile_id: @tile.id
      }
    else
      render json: {success: false}
    end
  end

  def render_tile_string
    render_to_string(
                     partial: 'client_admin/tiles/manage_tiles/single_tile',
                     locals: { presenter:  tile_presenter}
                    )
  end

  def render_single_tile
    render partial: 'client_admin/tiles/manage_tiles/single_tile', locals: { presenter: tile_presenter}
  end

  def tile_presenter
    @presenter ||= SingleTilePresenter.new(@tile, :html, @is_client_admin_action, browser.ie?)
  end

  def render_tile_preview_string
    render_to_string(action: 'show', layout:false)
  end

  def update_fields
    @tile_builder_form =  TileBuilderForm.new( @demo, builder_options.merge(tile: @tile))


    if @tile_builder_form.update_tile
      set_after_save_flash(@tile)
      if request.xhr?
        render_preview_and_single
      else
        redirect_to client_admin_tile_path(@tile_builder_form.tile)
      end
    else
      flash.now[:failure] = msg = "Sorry, we couldn't update this tile: " + @tile_builder_form.error_messages
      if request.xhr?
        response.headers["X-Message"]= msg
        head :unprocessable_entity and return
      else
        set_flash_for_no_image
        load_image_library
        render :edit
      end

    end
  end



  def set_after_save_flash(new_tile)
    flash[:success] ="Tile #{params[:action] || 'create' }d! We're resizing the graphics, which usually takes less than a minute."
  end

  def set_flash_for_no_image
    if @tile_builder_form.no_image
      flash.now[:failure] = render_to_string("client_admin/tiles/form/save_tile_without_an_image", layout: false, locals: { tile: @tile_builder_form.tile })
      flash[:failure_allow_raw] = true
    end
  end

  def load_image_library
    @tile_images = TileImage.all_ready.first(TileImage::PAGINATION_PADDING)
    @curr_page = 0
  end

  def builder_options
    {
      form_params: params[:tile_builder_form],
      creator: current_user,
      action: params[:action]
    }
  end


  def render_preview_and_single
    prepTilePreview
    render json: {
      tileStatus: @tile.status,
      tileId: @tile.id,
      tile: render_tile_string,
      preview: render_tile_preview_string,
    }
  end

end
