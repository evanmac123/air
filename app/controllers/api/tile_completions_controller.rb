# frozen_string_literal: true

module Api
  class TileCompletionsController < Api::ApiController
    include AllowGuestUsersConcern
    include ActsHelper

    prepend_before_action :find_tile

    def create
      unless current_user.in_board?(@tile.demo_id)
        not_found("flashes.failure_cannot_complete_tile_in_different_board")
        return false
      end

      remember_points_and_tickets

      if create_tile_completion.persisted?
        current_user.update_points(@tile.points)
        unless @tile.is_anonymous?
          ActFromTileCreatorJob.perform_later(tile: @tile, user: current_user)
        end
      end

      add_start_over_if_guest
      decide_if_tiles_can_be_done(current_user.tiles_to_complete_in_demo)

      render json: {
        starting_points: @starting_points,
        starting_tickets: @starting_tickets
      }
    end

    private

      def find_tile
        @tile ||= Tile.find(params[:tile_id])
      end

      def create_tile_completion
        free_form_response = params[:free_form_response] == "null" ? nil : params[:free_form_response]
        TileCompletion.create(
          tile_id: @tile.id,
          user: current_user,
          answer_index: params[:answer_index],
          free_form_response: free_form_response,
          custom_form: params[:custom_form]
        )
      end

      def find_board_for_guest
        @demo ||= @tile.demo
      end

      def remember_points_and_tickets
        @starting_points = current_user.points || 0
        @starting_tickets = current_user.tickets || 0
      end

      def add_start_over_if_guest
        session[:display_start_over_button] = true if current_user.is_guest?
      end
  end
end
