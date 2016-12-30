module ActsHelper
  ACT_BATCH_SIZE = 5

  def set_modals_and_intros
    unless current_user.is_a?(PotentialUser)
      @display_get_started_lightbox = current_user.display_get_started_lightbox

      if @display_get_started_lightbox && current_user
        @get_started_lightbox_message = welcome_message
        current_user.get_started_lightbox_displayed = true
      elsif current_user.is_a?(GuestUser)
        welcome_message_flash
      end

      current_user.save
    end
  end

  def display_admin_guide?
    current_user.is_client_admin && !current_user.displayed_activity_page_admin_guide
  end

  def welcome_message_flash
    keys_for_real_flashes = %w(success failure notice).map(&:to_sym)
    return if keys_for_real_flashes.any?{|key| flash[key].present?}

    flash.now[:success] = [welcome_message]
  end

  def welcome_message
    message_from_board = current_user.try(:demo).try(:persistent_message)

    if message_from_board.present?
      message_from_board
    else
      Demo.default_persistent_message
    end
  end

  def find_requested_acts(demo)
    offset = params[:offset].present? ? params[:offset].to_i : 0
    acts = Act.displayable_to_user(current_user, demo, ACT_BATCH_SIZE, offset).all
    @show_more_acts_btn = (acts.length == ACT_BATCH_SIZE)
    acts
  end

  def decide_if_tiles_can_be_done(satisfiable_tiles)
    @all_tiles_done = satisfiable_tiles.empty?
    @no_tiles_to_do = current_user.demo.tiles.active.empty?
  end
end
