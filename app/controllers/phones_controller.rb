class PhonesController < ApplicationController
  def create
    @user = User.find(params[:user_id])
    @user.join_game(params[:phone][:number])
    redirect_to page_path('broccoli')
  end
end
