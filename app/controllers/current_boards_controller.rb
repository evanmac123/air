class CurrentBoardsController < ApplicationController
  def update
    is_admin = current_user.is_client_admin? || current_user.is_site_admin?

    current_user.move_to_new_demo(params[:board_id])

    ping "Switched Board", {client_admin: is_admin, user: !is_admin}, current_user

    if current_user.is_client_admin? || current_user.is_site_admin?
      redirect_to :back
    else
      redirect_to activity_path
    end
  end
end
