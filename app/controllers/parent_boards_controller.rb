class ParentBoardsController < ApplicationController
  def show
    if current_user.have_access_to_parent_board? board_id
      ParentBoardUser.where(demo_id: board_id, user: current_user).destroy_all
      redirect_to activity_path(board_id: board_id)
    else
      redirect_to activity_path
    end
  end

  protected

  def board_id
    params[:id]
  end
end