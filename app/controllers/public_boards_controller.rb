class PublicBoardsController < ApplicationController
  prepend_before_filter :allow_guest_user

  def show
    board = find_current_board
    if override_public_board_setting || (board && board.is_public)
      if current_user.is_a?(User)
        add_board_to_user
      end

      redirect_to public_activity_path(public_slug: params[:public_slug])
    else
      render 'shared/public_board_not_found', layout: 'external_marketing'
    end
  end

  protected

  def find_current_board
    @current_board ||= Demo.public_board_by_public_slug(params[:public_slug])
  end

  def add_board_to_user
    if current_user.demos.include?(board)
      current_user.move_to_new_demo(board)
    else
      current_user.add_board(board)
      current_user.move_to_new_demo(board)
      current_user.get_started_lightbox_displayed = false
      current_user.session_count = 1
      current_user.save
      flash[:success] = "You've now joined the #{board.name} board!"
    end

  end
end
