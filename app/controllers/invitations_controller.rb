class InvitationsController < ApplicationController
  def show
    @player = Player.find_by_invitation_code(params[:id])
  end
end
