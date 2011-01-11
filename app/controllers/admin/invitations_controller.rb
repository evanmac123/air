class Admin::InvitationsController < AdminBaseController
  def create
    @player = Player.find(params[:player_id])
    @player.invite
  end
end
