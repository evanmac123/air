class TileCompletionsController < ApplicationController
  include AllowGuestUsersConcern
  include ActsHelper

  prepend_before_filter :find_tile

  #FIXME most of this functionality needs to to be moved into the TileCompletion
  #model

  def create
    unless current_user.in_board?(@tile.demo_id)
      not_found('flashes.failure_cannot_complete_tile_in_different_board')
      return false
    end


    remember_points_and_tickets

    if create_tile_completion(@tile)
      if  @tile.is_anonymous?
        update_user_points_anonymously @tile.points
      else
        create_act(@tile) 
      end
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

  private

    def find_tile
      @tile ||= Tile.find(params[:tile_id])
    end

    def create_tile_completion(tile)
      completion = TileCompletion.new(
        :tile_id => tile.id, :user => current_user,
        :answer_index => params[:answer_index],
        :free_form_response => params[:free_form_response],
        :custom_form => params[:custom_form]
      )
      completion.save
    end
    # TODO: move this from controller
    def create_act(tile)
      Act.create(
        user: current_user,
        demo_id: current_user.demo_id,
        inherent_points: tile.points,
        text: text_of_completion_act(tile),
        creation_channel: 'web'
      )
    end

    def update_user_points_anonymously points
      current_user.update_points(points,"web") 
    end

    def text_of_completion_act(tile)
      "completed the tile: \"#{tile.headline}\""
    end

    def find_board_for_guest
      @demo ||= @tile.demo
    end

    def remember_points_and_tickets
      @starting_points = current_user.points || 0
      @starting_tickets = current_user.tickets || 0
    end

    def persist_points_and_tickets
      flash[:previous_points] = @previous_points
      flash[:previous_tickets] = @previous_tickets
    end

    def add_start_over_if_guest
      session[:display_start_over_button] = true if current_user.is_guest?
    end
end
