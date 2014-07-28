class MuteController < ApplicationController
  def update
    current_user.board_memberships.where(demo_id: params[:id]).first.update_attributes(attribute_to_mute => params[:status])
    render nothing: true
  end
end
