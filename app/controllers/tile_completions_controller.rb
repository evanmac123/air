class TileCompletionsController < ApplicationController
  include UserInParentBoard

  prepend_before_filter :allow_guest_user, :only => :create

  def create
    tile = find_tile
    set_parent_board_user(tile.demo_id)
    
    unless current_user.in_board?(tile.demo_id)
      not_found
      return false
    end

    answer_index = params[:answer_index]

    remember_points_and_tickets

    if create_tile_completion(tile, answer_index)
      create_act(tile)
      schedule_completion_ping(tile)
    else
      flash[:failure] = "It looks like you've already done this tile, possibly in a different browser window or tab."
    end
    persist_points_and_tickets
    add_start_over_if_guest

    decide_if_tiles_can_be_done(Tile.satisfiable_to_user(current_user))    

    render json: {
      starting_points: @starting_points,
      starting_tickets: @starting_tickets
    }
  end

  protected

  def find_tile
    unless @_tile
      @_tile = Tile.find(params[:tile_id])
    end

    @_tile
  end

  def create_tile_completion(tile, answer_index)
    completion = TileCompletion.new(:tile_id => tile.id, :user => current_user, :answer_index => answer_index)
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
    @starting_points = current_user.points || 0
    @starting_tickets = current_user.tickets || 0
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
