class SubmittedTileNotificationsController < ApplicationController
  def index
    demo = Demo.where(id: params[:demo_id]).first

    if demo && current_user.in_board?(demo)
      current_user.move_to_new_demo demo

      redirect_to client_admin_tiles_path show_suggestion_box: true,
                                          user_submitted_tile_intro: true
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end
end
