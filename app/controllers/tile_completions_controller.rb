class TileCompletionsController < ApplicationController
  def create
    tile = find_tile
    TileCompletion.create!(:tile_id => tile.id, :user_id => current_user.id) unless tile.id == 0
    act = Act.create(user: current_user, demo_id: current_user.demo_id, inherent_points: tile.points, text: tile.text_of_completion_act, creation_channel: 'web')
    reply = ["That's right!", act.post_act_summary].join
    flash[:success] = reply
    check_sample_tile_done
    redirect_to :back
  end

  protected

  def find_tile
    if params[:tile_id].to_s == '0'
      current_user.sample_tile
    else
      Tile.find(params[:tile_id])
    end
  end

  def check_sample_tile_done
    set_talking_chicken_sample_tile_done(:multiple_choice)
  end
end
