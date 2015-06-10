class ReviewSuggestedTilesController < ApplicationController
  skip_before_filter :authorize

  def index
    user = User.where(id: params[:user_id]).first
    demo = Demo.where(id: params[:demo_id]).first

    if demo && user && EmailLink.validate_token(user, params[:token])
      if !current_user || current_user != user
        sign_in(user, 1)
      end

      if current_user.in_board?(demo)
        current_user.move_to_new_demo demo
      end

      redirect_to client_admin_tiles_path show_suggestion_box: true,
                                          user_submitted_tile_intro: true
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end
end
