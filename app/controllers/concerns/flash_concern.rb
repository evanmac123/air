module FlashConcern
  FLASHES_ALLOWING_RAW = %w(notice)

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

  def add_flash_to_headers(type:, message:)
    response.headers['X-Message-Type'] = type
    response.headers['X-Message'] = message
  end

  def set_outdated_session_json_flash
    add_flash_to_headers(type: :failure, message: I18n.t('flashes.failure_outdated_session'))
  end
end
