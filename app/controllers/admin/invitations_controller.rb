class Admin::InvitationsController < ApplicationController
  def create
    @player = Player.find(params[:player_id])
    @player.invite
  end
end
