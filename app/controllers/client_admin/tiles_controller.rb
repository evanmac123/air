class ClientAdmin::TilesController < ClientAdminBaseController
  
  include ClientAdmin::TilesHelper
  
  before_filter :get_demo
  before_filter :load_tags, only: [:new, :edit, :create, :update]

  def index
    # Update 'status' for tiles with 'start_time' and 'end_time' attributes (before you fetch the different tile groups)
    @demo.activate_tiles_if_showtime
    @demo.archive_tiles_if_curtain_call
    @active_tiles  = @demo.active_tiles_with_placeholders
    @archive_tiles = (@demo.archive_tiles_with_placeholders)[0,8]
    @draft_tiles = (@demo.draft_tiles_with_placeholders)[0,8]

    @first_active_tile_id = process_own_tile_completed

    @tile_just_activated = process_tile_just_activated
    
    @tiles_to_be_sent = @demo.digest_tiles(@demo.tile_digest_email_sent_at).count
    
    record_index_ping
  end

  def record_index_ping
    if param_path == :via_draft_preview
      TrackEvent.ping_action('Tile Preview Page - Draft', 'Clicked Back to Tiles button', current_user)
    elsif param_path == :via_posted_preview
      TrackEvent.ping_action('Tile Preview Page - Posted', 'Clicked Back to Tiles button', current_user)      
    elsif param_path == :via_archived_preview
      TrackEvent.ping_action('Tile Preview Page - Archive', 'Clicked Back to Tiles button', current_user)      
    end

    ping_page('Manage - Tiles', current_user)
  end
  private :record_index_ping
  
  def process_tile_just_activated
    tile_just_activated = flash[:tile_activated_flag] || false
    #empty out flash[:tile_activated] too
    tile_just_activated = flash[:tile_activated] || tile_just_activated
    if tile_just_activated && @demo.tiles.count == 1
      TrackEvent.ping_action('Tiles Page', 'Unlocked sharing', current_user)
    end
    
    tile_just_activated
  end
  private :process_tile_just_activated
  
  
  def process_own_tile_completed
    if !current_user.has_own_tile_completed_displayed? && !current_user.has_own_tile_completed_id.nil?
      current_user.has_own_tile_completed_displayed = true
      current_user.save!
      TrackEvent.ping_action('Tiles Page', "Activated Pop Over", current_user)
      
      current_user.has_own_tile_completed_id     
    else
      nil
    end    
  end
  private :process_own_tile_completed
  
  def new    
    @tile_builder_form = TileBuilderForm.new(@demo)
    if param_path == :via_index
      TrackEvent.ping_action('Tiles Page', 'Clicked Add New Tile', current_user)
    elsif param_path == :via_draft_preview
      TrackEvent.ping_action('Tile Preview Page - Draft', 'Clicked New Tile button', current_user)    
    elsif param_path == :via_posted_preview
      TrackEvent.ping_action('Tile Preview Page - Posted', 'Clicked New Tile button', current_user)    
    elsif param_path == :via_archived_preview
      TrackEvent.ping_action('Tile Preview Page - Archive', 'Clicked New Tile button', current_user)    
    end
    set_image_and_container
  end

  def create
    @tile_builder_form = TileBuilderForm.new(@demo, \
        parameters: params[:tile_builder_form], \
        creator: current_user, \
        image_container: params[:image_container])
    if @tile_builder_form.create_tile
      delete_old_image_container(:success)
      record_creator(@tile_builder_form.tile)
      set_after_save_flash(@tile_builder_form.tile)
      schedule_tile_creation_ping(@tile_builder_form.tile)
      redirect_to client_admin_tile_path(@tile_builder_form.tile)
    else
      delete_old_image_container(:failure)

      flash[:failure] = "Sorry, we couldn't save this tile: " + @tile_builder_form.error_messages
      set_image_and_container
      render "new"
    end
  end

  def update
    @tile = get_tile
    
    if params[:update_status]
      update_status
      if param_path == :via_preview_draft
        TrackEvent.ping_action('Tile Preview Page - Draft', 'Clicked Post button', current_user)
      elsif param_path == :via_preview_post
        TrackEvent.ping_action('Tile Preview Page - Posted', 'Clicked Archive button', current_user)
      elsif param_path == :via_preview_archive
        TrackEvent.ping_action('Tile Preview Page - Archive', 'Clicked Re-post button', current_user)
      elsif param_path == :via_index
        TrackEvent.ping_action('Tiles Page', 'Clicked Post to activate tile', current_user)
      end
    else
      update_fields        
    end
  end

  def show
    @tile = get_tile
    @tile_just_activated = flash[:tile_activated] || false
    flash[:tile_activated_flag] = @tile_just_activated
    if @tile.draft?
      @show_tile_post_guide = !current_user.displayed_tile_post_guide? && @tile.demo.non_activated?
      current_user.displayed_tile_post_guide = true
      current_user.save!
    elsif @tile_just_activated
      @show_tile_success_guide = !current_user.displayed_tile_success_guide? && @tile.demo.tiles.active.count == 1
      current_user.displayed_tile_success_guide = true
      current_user.save!
    elsif !current_user.share_section_intro_seen
      @show_share_section_intro = true
      current_user.share_section_intro_seen = true
      current_user.save!
    end

    @back_to_tiles_href = set_back_to_tiles_href
  end

  def edit
    tile = get_tile
    @tile_builder_form = tile.to_form_builder 
    if param_path == :via_draft_preview
      TrackEvent.ping_action('Tile Preview Page - Draft', 'Clicked Edit button', current_user)
    elsif param_path == :via_posted_preview
      TrackEvent.ping_action('Tile Preview Page - Posted', 'Clicked Edit button', current_user)      
    elsif param_path == :via_archived_preview
      TrackEvent.ping_action('Tile Preview Page - Archive', 'Clicked Edit button', current_user)      
    end
    set_image_and_container
  end

  def sort
    @tile = get_tile
    #Logger.new("#{Rails.root}/log/my.log").info("#{@tile.id} ")
    #@last_tile = @tile.first_tile_beyond_visible_in_manage
    Tile.insert_tile_between(params[:left_tile_id], @tile.id, params[:right_tile_id], params[:status])
    @tile.reload

    if params[:source_section].present?
      status_name = params[:source_section][:name]
      ids = params[:source_section][:presented_ids] || []
      tile_demo_id = get_demo
      needs_tiles = ids.count >= 8 ? 0 : (8 - ids.count)
      @last_tiles = Tile.where{ (demo_id == tile_demo_id) & (status == status_name) & (id << ids) }.first(needs_tiles)
    end

    tile_status_updated_ping @tile, "Dragged tile to move"
  end
  
  def active_tile_guide_displayed
    current_user.displayed_active_tile_guide=true
    current_user.save!
    TrackEvent.ping_action('Tiles Page', 'Clicked Got It button in Publish orientation pop-over', current_user)

    render nothing: true
  end
  
  def main_menu_tile_guide_displayed
    TrackEvent.ping_action('Tiles Page', 'Clicked Got It button in orientation pop-over', current_user)
    render nothing: true
  end

  def clicked_first_completion_got_it
    TrackEvent.ping_action('Tiles Page', "Pop Over - clicked Got It", current_user)
    render nothing: true    
  end
  
  def activated_try_your_board
    TrackEvent.ping_action('Tiles Page', 'Clicked Got It button in Share orientation pop-over', current_user)
    TrackEvent.ping_action('Tiles Page', "Activated Try your board as a user pop-over", current_user)
    render nothing: true        
  end
  
  def clicked_try_your_board_got_it
    TrackEvent.ping_action('Tiles Page', "Clicked Got It button in Try As User orientation pop-over", current_user)
    render nothing: true        
  end
  
  def clicked_post_got_it
    TrackEvent.ping_action('Tile Preview Page - Draft', "Clicked Got It button in orientation pop-over", current_user)
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
    is_new = @tile.activated_at.nil?
    if @tile.update_status(params[:update_status])
      flash[:tile_activated] = is_new && @tile.active?
      flash[:tile_activated_flag] = is_new && @tile.active?
      flash[:success] = "The #{@tile.headline} tile has been #{success}"
      tile_status_updated_ping @tile, "Clicked button to move"
    else
      flash[:failure] = "There was a problem #{failure} this tile. Please try again."
    end

    redirect_to :back
  end
  
  def update_fields
    @tile_builder_form = TileBuilderForm.new(@demo, \
        parameters: params[:tile_builder_form], \
        tile: @tile, \
        image_container: params[:image_container])

    if @tile_builder_form.update_tile
      delete_old_image_container(:success)

      set_after_save_flash(@tile_builder_form.tile)
      redirect_to client_admin_tile_path(@tile_builder_form.tile)
    else
      delete_old_image_container(:failure)

      flash[:failure] = "Sorry, we couldn't update this tile: " + @tile_builder_form.error_messages
      set_image_and_container
      render :edit
    end
  end

  def set_after_save_flash(new_tile)
    activate_url = client_admin_tile_path(new_tile, update_status: Tile::ACTIVE)
    edit_url = edit_client_admin_tile_path(new_tile)
    already_active = new_tile.active?

    flash[:success] = render_to_string("preview_after_save_flash", layout: false, locals: {action: params[:action], edit_url: edit_url, activate_url: activate_url, already_active: already_active})
    flash[:success_allow_raw] = true
  end

  def schedule_tile_creation_ping(tile)
    ping('Tile - New', {tile_source: "Self Created", is_public: tile.is_public, is_copyable: tile.is_copyable, tag: tile.tile_tags.first.try(:title)}, current_user)
  end

  def set_image_and_container
    @container_id = set_container_id
    @image_url = set_image_url
    set_flash_for_no_image
  end

  def set_container_id
    if params["image_container"].present? && params["image_container"] != "no_image"
      ImageContainer.find(params["image_container"]).id
    elsif params["image_container"] == "no_image"
      "no_image"
    elsif params[:tile_builder_form].present? && params[:tile_builder_form][:image].present?
      ImageContainer.tile_image(params[:tile_builder_form][:image]).id
    else
      nil
    end
  end

  def set_image_url
    if @container_id.to_i > 0
      ImageContainer.find(@container_id).image.url
    else
      @tile_builder_form.image.url
    end
  end

  def set_flash_for_no_image
    if params["image_container"] == "no_image" && params[:action] == "update"
      flash[:failure] = render_to_string("save_tile_without_an_image", layout: false, locals: { tile: @tile_builder_form.tile })
      flash[:failure_allow_raw] = true
    end
  end

  def delete_old_image_container(tile_saved)
    if params["old_image_container"].to_i > 0 && \
        (tile_saved == :success || params["image_container"].to_i <= 0) 

      ImageContainer.find(params["old_image_container"]).destroy
    end
  end

  def record_creator(tile)
    tile.creator = current_user
    tile.save!
  end

  def set_back_to_tiles_href
    set_back_to_tiles_path_tag
    return default_back_to_tiles_path unless request.referer.present?

    @back_to_tiles_href = case request.referer.split("/").last
                          when 'inactive_tiles'
                            client_admin_inactive_tiles_path(path: @tag)
                          when 'draft_tiles'
                            client_admin_draft_tiles_path(path: @tag)
                          else
                            default_back_to_tiles_path
                          end
  end

  def default_back_to_tiles_path
    client_admin_tiles_path(path: @tag)  
  end

  def set_back_to_tiles_path_tag
    @tag = if @tile.active?
             :via_posted_preview
           elsif @tile.archived?
             :via_archived_preview
           else
             :via_draft_preview
           end
  end

  def tile_status_updated_ping tile, action
    ping('Moved Tile in Manage', {action: action, tile_id: tile.id}, current_user)
  end
end
