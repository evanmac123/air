class CurrentBoardsController < ApplicationController
  def update
    if current_user.move_to_new_demo(params[:board_id])
    end

    redirect_to activity_path
  end
end
