class BoardMembershipsController < ApplicationController
  def destroy
    board_to_leave = Demo.find(params[:id])
    remover = RemoveUserFromBoard.new(current_user, board_to_leave)
    
    if remover.remove!
      flash[:success] = "OK, you've left the #{board_to_leave.name}"
    else
      flash[:failure] = failure_message(remover.error_messages)
    end

    redirect_to :back
  end

  protected

  def failure_message(error_messages)
    "Sorry, we weren't able to remove you from that board: #{error_messages.join(', ')}."
  end
end
