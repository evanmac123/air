class ClientAdmin::PublicBoardsController < ClientAdminBaseController
  def create
    demo = current_user.demo

    if demo.create_public_slug!
      @board_is_public = true
      render partial: "client_admin/shares/public_board_controls"
    end
  end
end
