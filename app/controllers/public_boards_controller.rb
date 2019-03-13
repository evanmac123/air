# frozen_string_literal: true

class PublicBoardsController < ApplicationController
  include AllowGuestUsersConcern

  def show
    @board ||= find_board_for_guest
    if @board && @board.is_public
      if current_user.is_a?(User)
        add_board_to_user(@board)
        redirect_to activity_path
      else
        redirect_to public_activity_path(public_slug: params[:public_slug])
      end
    else
      render "shared/public_board_not_found", layout: "marketing_site"
    end
  end

  private

    def find_board_for_guest
      @board ||= Demo.where(public_slug: params[:public_slug]).first
    end

    def add_board_to_user(board)
      if current_user.demos.include?(board)
        current_user.move_to_new_demo(board)
      else
        current_user.add_board(board)
        current_user.move_to_new_demo(board)
        current_user.get_started_lightbox_displayed = false
        current_user.save
        flash[:success] = "You've now joined the #{board.name} board!"
      end
    end
end
