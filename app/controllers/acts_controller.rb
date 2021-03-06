# frozen_string_literal: true

class ActsController < ApplicationController
  # This is still such shit awful code. Trying to do so many things at once. Fuck.
  include AllowGuestUsersConcern
  include AuthorizePublicBoardsConcern
  include TileBatchHelper
  include ActsHelper
  include TileEmailTrackingConcern
  include ThemingConcern

  prepend_before_action :authenticate
  before_action :set_theme

  def index
    @ctrl_data = {
      currentBoard: current_user.demo.id,
      currentUser: current_user.id,
      isGuestUser: current_user.is_a?(GuestUser),
      loadedBoard: true,
      activityBoard: true
    }.to_json
    @react_spa = true

    render template: "react_spa/show"
  end

  private

    def authenticate
      return true if authenticate_by_tile_token
      return true if authenticate_as_potential_user
      return true if guest_user?
    end

    def authenticate_by_tile_token
      # TODO: This is too coupled to authentication and a huge mess...
      return false unless params[:tile_token]
      user = User.find_by(id: params[:user_id])

      if should_authenticate_by_tile_token?(params[:tile_token], user)
        user.move_to_new_demo(params[:demo_id]) if params[:demo_id].present?
        sign_in(user, :remember_user) if user.end_user_in_all_boards?

        if signed_in?
          current_user.move_to_new_demo(params[:demo_id]) if current_user != user
          track_tile_email_logins(user: current_user)

          flash[:success] = "Welcome back, #{current_user.first_name}!"
          redirect_to redirect_path_for_tile_token_auth
        else
          set_open_graph_tile
          return false
        end
      else
        return false
      end
    end

    def should_authenticate_by_tile_token?(tile_token, user)
      user && EmailLink.validate_token(user, tile_token)
    end
end

# http://localhost:3000/acts?demo_id=920&amp;email_type=follow_up_digest&amp;subject_line=%255BTest%255D%2520Don%2527t%2520Miss%253A%2520Update%2520on%2520FSA%2520cards&amp;tile_id=42214&amp;tile_token=f536f370d35bd5ef9ddc2b7ade6e2d6adc845229&amp;tiles_digest_id=test&amp;user_id=437728
