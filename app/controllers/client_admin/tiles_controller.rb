require 'custom_responder'
class ClientAdmin::TilesController < ClientAdminBaseController
  include ClientAdmin::TilesHelper
  include ClientAdmin::TilesPingsHelper
  include CustomResponder

  before_filter :get_demo
  before_filter :load_tags, only: [:new, :edit, :update]
  before_filter :permit_params, only: [:create, :update]

  def index
    @all_tiles = @demo.tiles.group_by { |t| t.status }

    @actives = tiles_by_grp(Tile::ACTIVE)
    @archives = tiles_by_grp(Tile::ARCHIVE)
    @drafts =  tiles_by_grp(Tile::DRAFT)
    @suggesteds = tiles_by_grp(Tile::USER_SUBMITTED)  | tiles_by_grp(Tile::IGNORED)
    @submitteds = tiles_by_grp(Tile::USER_SUBMITTED)

    @active_tiles  = @demo.active_tiles_with_placeholders(@actives)

    @archive_tiles = (@demo.archive_tiles_with_placeholders @archives)[0,4]
    @draft_tiles = @demo.draft_tiles_with_placeholders @drafts
    @suggested_tiles = @demo.suggested_tiles_with_placeholders @suggesteds
    @user_submitted_tiles_counter = @submitteds.count


    @allowed_to_suggest_users = @demo.users_that_allowed_to_suggest_tiles

    intro_flags_index
    @accepted_tile = Tile.find(session.delete(:accepted_tile_id)) if session[:accepted_tile_id]
    record_index_ping
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


  def new
    @tile_builder_form =  @demo.m_tiles.build(status: Tile::DRAFT)
    new_or_edit @tile_builder_form
  end


  def edit
    @tile_builder_form =  get_tile
    new_or_edit @tile_builder_form
  end

  def update
    @tile = get_tile
    if params[:update_status]
      update_status
    else
      @tile.assign_attributes(params[:tile_builder_form])
      update_or_create @tile do
        render_preview_and_single
      end
    end
  end

  def create
    @tile_builder_form =  @tile = @demo.m_tiles.build(params[:tile_builder_form].merge(creator_id: current_user.id))

    update_or_create @tile_builder_form do
      schedule_tile_creation_ping(@tile_builder_form, "Self Created")
      render_preview_and_single
    end
  end

  def destroy
    @tile = get_tile
    if @tile
      @tile.destroy
      #FIXME why is the ping destroy tile ping necessary?
      destroy_tile_ping params[:page]
    end

    if request.xhr?
      head :ok
    else
      redirect_to client_admin_tiles_path
    end
  end

  def sort
    #FIXME this code sucks!!! simply posting of tile ids and current positions
    #would simplify this whole process
    @tile = get_tile

    Tile.insert_tile_between(
      params[:left_tile_id],
      @tile.id,
      params[:right_tile_id],
      params[:status],
      params[:redigest]
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
    # tile_status_updated_ping @tile, "Dragged tile to move"

  end

  #FIXME should refactor and cosolidate the existing update method but the functionality is too
  #convoluted to fix now.

  def status_change
    @tile = get_tile

    @tile.update_status(params[:update_status])
    presenter = present(@tile, SingleAdminTilePresenter, {is_ie: browser.ie?})
    render partial: 'client_admin/tiles/manage_tiles/single_tile', locals: { presenter: presenter}
  end

  def update_explore_settings
    tpf = TilePublicForm.new(get_tile, params[:tile_public_form])
    tpf.save
    @tile = tpf.tile
    render_preview_and_single
  end

  def duplicate
    @tile = get_tile.copy_inside_demo(current_user.demo, current_user)
    render_preview_and_single
  end

  def next_tile
    @tile = Tile.next_manage_tile get_tile, 1, false
    if @tile
      render_preview_and_single
    else
      render nothing: true
    end
  end

  private

  def tiles_by_grp grp
    tiles = @all_tiles[grp] || []
    tiles.sort_by{|t| t.position}.reverse
  end

  def permit_params
    params.require(:tile_builder_form).permit!
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


  def prepTilePreview
    @prev, @next = @demo.bracket @tile
    @show_share_section_intro = show_share_section_intro
  end


  def intro_flags_index
    @board_is_brand_new = @all_tiles.empty? && params[:show_suggestion_box] != "true"
    @show_suggestion_box_intro =  should_show_suggestion_box_intro?
    @user_submitted_tile_intro =   should_show_submitted_tile_intro?
    @manage_access_prompt = should_show_manage_access_prompt?
  end

  def should_show_submitted_tile_intro?
     val = !current_user.user_submitted_tile_intro_seen && @submitteds.any?
     val = val && !@show_suggestion_box_intro && params[:user_submitted_tile_intro]

     if val
       current_user.user_submitted_tile_intro_seen = true
       return current_user.save
     end
  end

  def should_show_suggestion_box_intro?
    if !current_user.suggestion_box_intro_seen
      current_user.suggestion_box_intro_seen = true
      return current_user.save
    end
  end

  def should_show_manage_access_prompt?
    if !current_user.manage_access_prompt_seen &&  tile_suggestion_enabled?
      current_user.manage_access_prompt_seen = true
      return current_user.save
    end
  end

  def tile_suggestion_enabled?
    @user_submitted_tiles_counter > 0 ||
      @allowed_to_suggest_users.count > 0 ||
      @demo.everyone_can_make_tile_suggestions
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
    #FIXME what is this offset
    tile = current_user.demo.tiles.where(id: params[:id]).first
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
    @presenter ||= present(@tile, SingleAdminTilePresenter, {is_ie: browser.ie?})
  end

  def render_tile_preview_string
    render_to_string(action: 'show', layout:false)
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
