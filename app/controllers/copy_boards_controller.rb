class CopyBoardsController < ClientAdminBaseController
  def create
    demo = Demo.where(id: params[:board_id]).first
    if current_user.have_access_to_parent_board? demo
      current_user.copy_active_tiles_from_demo(demo)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end
end