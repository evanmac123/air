class MuteFollowupsController < ApplicationController
  def update
    current_user.board_memberships.where(demo_id: params[:id]).first.update_attributes(followup_muted: params[:status])
    render nothing: true
  end
end
