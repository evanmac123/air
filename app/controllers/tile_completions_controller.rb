class TileCompletionsController < ApplicationController
  def create
    tile = Tile.find(params[:tile_id])
    TileCompletion.create!(:tile_id => tile.id, :user_id => current_user.id)    
    act = Act.create(user: current_user, demo_id: current_user.demo_id, inherent_points: tile.points, text: tile.text_of_completion_act, creation_channel: 'web')
    reply = ["That's right!", act.post_act_summary].join
    flash[:success] = reply
    redirect_to :back
  end
end
