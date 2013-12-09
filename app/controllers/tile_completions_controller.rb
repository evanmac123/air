class TileCompletionsController < ApplicationController
  prepend_before_filter :allow_guest_user, :only => :create

  def create
    tile = find_tile
    act = create_act(tile)
    create_tile_completion(tile)

    flash[:success] = reply(act)
    redirect_to :back
  end

  protected

  def find_tile
    Tile.find(params[:tile_id])
  end

  def create_tile_completion(tile)
    TileCompletion.create!(:tile_id => tile.id, :user => current_user)
  end

  def create_act(tile)
    Act.create(user: current_user, demo_id: current_user.demo_id, inherent_points: points(tile), text: tile.text_of_completion_act, creation_channel: 'web')
  end

  def reply(act)
    ["Tile complete:", act.post_act_summary].join
  end

  def points(tile)
    tile.points
  end
end
