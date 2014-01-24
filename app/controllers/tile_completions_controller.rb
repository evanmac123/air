class TileCompletionsController < ApplicationController
  prepend_before_filter :allow_guest_user, :only => :create

  def create
    tile = find_tile
    act = create_act(tile)
    create_tile_completion(tile)

    session[:display_start_over_button] = true if current_user.is_guest?
    flash[:success] = reply(act)
    redirect_to :back
  end

  protected

  def find_tile
    unless @_tile
      @_tile = Tile.find(params[:tile_id])
    end

    @_tile
  end

  def create_tile_completion(tile)
    TileCompletion.create!(:tile_id => tile.id, :user => current_user)
    ping('Tile - Completed', {tile_id: tile.id}, current_user)
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

  def find_current_board
    find_tile.demo
  end
end
