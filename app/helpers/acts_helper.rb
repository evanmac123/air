module ActsHelper
  def set_modals_and_intros
    if current_user.display_get_started_lightbox || params[:welcome_modal].present?
      @display_board_welcome_message = true
      current_user.update_attributes(get_started_lightbox_displayed: true)
    end
  end

  def welcome_message_flash
    keys_for_real_flashes = %w(success failure notice).map(&:to_sym)
    return if keys_for_real_flashes.any?{|key| flash[key].present?}

    flash.now[:success] = [welcome_message]
  end

  def decide_if_tiles_can_be_done(satisfiable_tiles)
    @all_tiles_done = satisfiable_tiles.empty?
    @no_tiles_to_do = current_user.demo.tiles.active.empty?
  end

  def redirect_path_for_tile_token_auth
    set_tile_id_for_open_graph

    tile = get_tile_from_params
    if tile.present?
      tiles_path({ tile_id: params[:tile_id] })
    else
      activity_path
    end
  end

  def set_tile_id_for_open_graph
    session[:open_graph_tile_id] = params[:tile_id]
  end

  def set_open_graph_tile_for_admin
    tile = Tile.find_by(id: params[:tile_id])
    if tile.present?
      cookies[:og_image] = { value: tile.image.url, expires: 1.hour.from_now }
      cookies[:og_title] = { value: tile.headline, expires: 1.hour.from_now }
    end
  end

  def get_tile_from_params
    if current_user && params[:tile_id].present?
      current_board.tiles.find_by(id: params[:tile_id])
    end
  end
end
