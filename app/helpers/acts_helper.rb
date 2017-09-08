module ActsHelper
  def set_modals_and_intros
    if current_user.display_get_started_lightbox
      @display_board_welcome_message = true
      current_user.update_attributes(get_started_lightbox_displayed: true)
    end
  end

  def welcome_message_flash
    keys_for_real_flashes = %w(success failure notice).map(&:to_sym)
    return if keys_for_real_flashes.any?{|key| flash[key].present?}

    flash.now[:success] = [welcome_message]
  end

  def find_requested_acts(demo, per_page)
    page = params[:page] || 1
    acts = Act.displayable_to_user(current_user, demo, page, per_page)
    @show_more_acts_btn = !acts.last_page?
    acts
  end

  def decide_if_tiles_can_be_done(satisfiable_tiles)
    @all_tiles_done = satisfiable_tiles.empty?
    @no_tiles_to_do = current_user.demo.tiles.active.empty?
  end
end
