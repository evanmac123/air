class ClientAdmin::PublicBoardsController < ClientAdminBaseController
  before_filter :require_xhr
  before_filter :find_demo

  def create
    @demo.update_attributes(is_public: true)
    @board_is_public = true
    render nothing: true
    #render partial: "client_admin/shares/public_board_controls"
  end

  def destroy
    @demo.update_attributes(is_public: false)
    @board_is_public = false
    render nothing: true
    #render partial: "client_admin/shares/public_board_controls"
  end

  protected

  def require_xhr
    redirect_to :back unless request.xhr?
  end

  def find_demo
    @demo = current_user.demo
  end
end
