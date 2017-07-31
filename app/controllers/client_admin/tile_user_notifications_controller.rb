class ClientAdmin::TileUserNotificationsController < ClientAdminBaseController
  def create
    tile = current_board.tiles.where(id: tile_user_notification_params[:tile_id]).first

    if tile.present?
      attempt_to_create_notification
    else
      render_json_access_denied
    end
  end

  private

    def attempt_to_create_notification
      tile_user_notification = current_user.tile_user_notifications.new(tile_user_notification_params)

      if tile_user_notification.save
        tile_user_notification.deliver_notifications
        render json: tile_user_notification
      else
        render json: { errors: tile_user_notification.errors.full_messages }, status: 422
      end
    end

    def tile_user_notification_params
      params.require(:tile_user_notification).permit(
        :tile_id,
        :subject,
        :message,
        :answer,
        :scope_cd,
        :send_at
      )
    end
end
