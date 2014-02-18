class TileCompletionsController < ApplicationController
  prepend_before_filter :allow_guest_user, :only => :create

  def create
    tile = find_tile

    remember_points_and_tickets

    if create_tile_completion(tile)
      create_act(tile)
      persist_points_and_tickets
      schedule_completion_ping(tile)
      add_start_over_if_guest
    else
      flash[:failure] = "It looks like you've already done this tile, possibly in a different browser window or tab."
    end

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
    completion = TileCompletion.new(:tile_id => tile.id, :user => current_user)
    completion.save
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

  def remember_points_and_tickets
    @previous_points = current_user.points || 0
    @previous_tickets = current_user.tickets || 0
  end

  def persist_points_and_tickets
    flash[:previous_points] = @previous_points
    flash[:previous_tickets] = @previous_tickets
  end

  def schedule_completion_ping(tile)
    ping('Tile - Completed', {tile_id: tile.id}, current_user)
  end

  def add_start_over_if_guest
    session[:display_start_over_button] = true if current_user.is_guest?
  end
end
