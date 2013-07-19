class TileCompletionsController < ApplicationController
  def create
    tile = Tile.find(params[:tile_id])
    act = Act.create(user: current_user, demo_id: current_user.demo_id, inherent_points: tile.points, text: tile.text_of_completion_act)
    reply = ["That's right!", act.post_act_summary].join
    flash[:success] = reply
    redirect_to :back
  end
end
