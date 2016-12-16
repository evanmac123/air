module AirboFlashHelper
  FLASHES_ALLOWING_RAW = %w(notice)
  
  ##FLASH MGMT =>
  def add_success(text)
    @flash_successes_for_next_request << text
  end

  def add_failure(text)
    @flash_failures_for_next_request << text
  end

  def initialize_flashes
    @flash_successes_for_next_request = []
    @flash_failures_for_next_request = []
  end

  def merge_flashes
    unless @flash_successes_for_next_request.empty?
      flash[:success] = (@flash_successes_for_next_request + [flash[:success]]).join(' ')
    end

    unless @flash_failures_for_next_request.empty?
      flash[:failure] = (@flash_failures_for_next_request + [flash[:failure]]).join(' ')
    end
  end

  def add_persistent_message
    return unless use_persistent_message?
    return unless current_user.try(:is_guest?)
    demo = current_user.try(:demo)
    return if demo && $rollout.active?(:skip_persistent_message, demo)

    keys_for_real_flashes = %w(success failure notice).map(&:to_sym)
    return if keys_for_real_flashes.any?{|key| flash[key].present?}

    flash.now[:success] = [persistent_message_or_default(current_user)]
    flash.now[:success_allow_raw] = demo.try(:allow_raw_in_persistent_message)
    @persistent_message_shown = true
  end

  def persistent_message_or_default(user)
    message_from_board = user.try(:demo).try(:persistent_message)

    if message_from_board.present?
      message_from_board
    else
      Demo.default_persistent_message
    end
  end

  def use_persistent_message?
    !(@display_get_started_lightbox) && @use_persistent_message.present?
  end
end
