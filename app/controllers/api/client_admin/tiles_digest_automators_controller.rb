class Api::ClientAdmin::TilesDigestAutomatorsController < Api::ClientAdminBaseController

  def create
    automator = get_automator
    automator.set_deliver_date
    create_or_update_automator(automator: automator)
  end

  def update
    automator = TilesDigestAutomator.find(params[:id])

    if automator.demo == current_board
      create_or_update_automator(automator: automator)
    else
      set_outdated_session_json_flash
      render_json_access_denied
    end
  end

  def destroy
    automator = TilesDigestAutomator.find(params[:id])

    if automator.demo == current_board
      render json: automator.destroy
    else
      set_outdated_session_json_flash
      render_json_access_denied
    end
  end

  private

    def get_automator
      current_board.tiles_digest_automator || current_board.build_tiles_digest_automator
    end

    def create_or_update_automator(automator:)
      automator.assign_attributes(tiles_digest_automator_params)
      if automator.save
        automator.schedule_delivery
        render json: automator
      else
        render json: automator.errors
      end
    end

    def tiles_digest_automator_params
      params.require(:tiles_digest_automator).permit(:deliver_date, :day, :time, :frequency_cd, :has_follow_up, :include_sms, :include_unclaimed_users) if params[:tiles_digest_automator].present?
    end
end
