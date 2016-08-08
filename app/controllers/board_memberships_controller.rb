class BoardMembershipsController < ApplicationController
  # FIXME: The action is only hit fromt he board_settings view, which is pegged for removal
  def destroy
    @board_to_leave = Demo.find(params[:id])
    if current_user.has_only_board?(@board_to_leave)
      delete_user_account
    else
      remove_user_from_single_board
    end
  end

  protected

  def delete_user_account
    deleter = DeleteUserAccount.new(current_user)
    if deleter.delete!
      sign_out
      redirect_to root_path
    else
      flash[:failure] = failure_message(deleter.error_messages)
      redirect_to :back
    end
  end

  def remove_user_from_single_board
    remover = RemoveUserFromBoard.new(current_user, @board_to_leave)
    if remover.remove!
      flash[:success] = "OK, you've left the #{@board_to_leave.name}"
    else
      flash[:failure] = failure_message(remover.error_messages)
    end

    redirect_to :back
  end

  def failure_message(error_messages)
    "Sorry, we weren't able to remove you from that board: #{error_messages.join(', ')}."
  end
end
