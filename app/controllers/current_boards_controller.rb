class CurrentBoardsController < UserBaseController
  def update
    current_board_membership = current_user.move_to_new_demo(params[:board_id])
    is_admin = current_board_membership.is_client_admin || current_user.is_site_admin?

    ping_board_switch(is_admin)

    if params[:admin_view_board] || !is_admin
      redirect_to activity_path
    else
      redirect_to :back
    end
  end

  private

    def ping_board_switch(is_admin)
      ping("Switched Board", {client_admin: is_admin, user: !is_admin}, current_user)
    end
end
