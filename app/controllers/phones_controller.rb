class PhonesController < ApplicationController
  def create
    @player = Player.find(params[:player_id])
    @player.join_game(params[:phone][:number])
    redirect_to page_path('broccoli')
  end
end
