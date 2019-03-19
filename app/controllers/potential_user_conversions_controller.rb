# frozen_string_literal: true

class PotentialUserConversionsController < ApplicationController
  def create
    @potential_user = PotentialUser.find_by(id: session[:potential_user_id])
    if @potential_user
      full_user = @potential_user.convert_to_full_user!(params[:potential_user_name])
      response = if full_user
        full_user.delay.credit_game_referrer(@potential_user.game_referrer)
        session[:potential_user_id] = nil

        flash[:success] = "Welcome, #{full_user.name}"
        sign_in full_user
        render_user_data(full_user)
      else
        { error: "This invite link has already been used." }
      end
      render json: response
    end
  end

  private
    def render_user_data(user)
      if user
        {
          isGuestUser: user.is_guest?,
          isEndUser: user.try(:end_user?) || false,
          isClientAdmin: user.try(:is_client_admin?) || false,
          isPotentialUser: user.try(:is_potential_user?) || false,
          name: user.try(:name),
          id: user.try(:id),
          points: user.try(:points) || 0,
          tickets: user.try(:tickets) || 0,
          ticketThresholdBase: user.try(:ticket_threshold_base),
          email: user.try(:email),
          numOfIncompleteTiles: user.tiles_to_complete_in_demo.count,
          path: "/users/#{user.slug}",
          displayBoardWelcomeMessage: @display_board_welcome_message || false
        }
      end
    end
end
