class Api::ClientAdmin::TilesDigestAutomatorsController < Api::ClientAdminBaseController

  include ClientAdmin::SharesHelper

  before_action :authorize_tenant
  before_action :get_automator

  def update
    @automator.assign_attributes(tiles_digest_automator_params)
    @automator.reset_deliver_date

    if @automator.save
      @automator.schedule_delivery
      render :show, status: 200
    else
      render json: @automator.errors, status: 400
    end
  end

  def destroy
    @automator.destroy
    render :show, status: 200
  end

  private

    def authorize_tenant
      unless params[:demo_id] == current_board.id.to_s
        set_outdated_session_json_flash
        render_json_access_denied
      end
    end

    def get_automator
      @automator = current_board.tiles_digest_automator || current_board.build_tiles_digest_automator
    end

    def tiles_digest_automator_params
      params.require(:tiles_digest_automator).permit(:day, :time, :frequency_cd, :has_follow_up, :include_sms, :include_unclaimed_users) if params[:tiles_digest_automator].present?
    end
end
