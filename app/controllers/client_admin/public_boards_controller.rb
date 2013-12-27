class ClientAdmin::PublicBoardsController < ClientAdminBaseController
  before_filter :require_xhr
  before_filter :find_demo

  def create
    @demo.create_public_slug!
    @board_is_public = true
    render partial: "client_admin/shares/public_board_controls"
  end

  def destroy
    @demo.clear_public_slug!
    @board_is_public = false
    render partial: "client_admin/shares/public_board_controls"
  end

  protected

  def require_xhr
    redirect_to :back unless request.xhr?
  end

  def find_demo
    @demo = current_user.demo
  end
end
