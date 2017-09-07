class ClientAdmin::TileUserNotificationsController < ClientAdminBaseController
  def create
    tile = current_board.tiles.where(id: tile_user_notification_params[:tile_id]).first

    if tile.present?
      create_notification
    else
      render_json_access_denied
    end
  end

  def new
    tile = current_board.tiles.where(id: tile_user_notification_params[:tile_id]).first

    if tile.present?
      tile_user_notification = current_user.tile_user_notifications.new(tile_user_notification_params)

      tile_user_notification.recipient_count = tile_user_notification.user_count
      render json: tile_user_notification, status: 200
    else
      render_json_access_denied
    end
  end

  private

    def create_notification
      if params[:test_notification].present?
        attempt_to_create_test_notification
      else
        attempt_to_create_notification
      end
    end

    def attempt_to_create_notification
      tile_user_notification = current_user.tile_user_notifications.new(tile_user_notification_params)

      if tile_user_notification.save
        tile_user_notification.deliver_notifications
        render json: { tile_user_notification: tile_user_notification.decorate_for_tile_stats_table }, status: 200
      else
        render_failure(tile_user_notification: tile_user_notification)
      end
    end

    def attempt_to_create_test_notification
      tile_user_notification = current_user.tile_user_notifications.new(tile_user_notification_params)

      if tile_user_notification.valid?
        tile_user_notification.deliver_test_notification(user: current_user)
        render json: { tile_user_notification: tile_user_notification.decorate_for_tile_stats_table }
      else
        render_failure(tile_user_notification: tile_user_notification)
      end
    end

    def render_failure(tile_user_notification:)
      add_flash_to_headers(type: "notice", message: tile_user_notification.errors.full_messages.to_sentence.capitalize)

      render json: { errors: tile_user_notification.errors.full_messages }, status: 422
    end

    def tile_user_notification_params
      params.require(:tile_user_notification).permit(
        :tile_id,
        :subject,
        :message,
        :answer_idx,
        :scope_cd
      )
    end
end
