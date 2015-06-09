class ReviewSuggestedTilesController < ApplicationController
  def index
    user = User.where(id: params[:user_id]).first
    demo = Demo.where(id: params[:demo_id]).first
    if demo && user && user.is_client_admin && EmailLink.validate_token(user, params[:token])
      if !current_user || current_user != user
        sign_in(user)
      end

      if current_user.in_board?(demo)
        current_user.move_to_new_demo demo
      end

      redirect_to client_admin_tiles_path show_suggestion_box: true,
                                          suggested_tile_intro: true
    else
      flash[:failure] = "That page doesn't exist."
      redirect_to "/"
    end
  end
end
