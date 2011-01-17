class PhonesController < ApplicationController
  def create
    @user = User.find_by_slug(params[:user_id])
    @user.join_game(params[:phone][:number])

    flash[:success] = "Welcome to the game! You're now signed in. Players' activity is below to the left. The basic rules are below to the right."
    redirect_to "/activity"
  end
end
