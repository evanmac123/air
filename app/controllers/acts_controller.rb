class ActsController < ApplicationController
  include TileBatchHelper
  include ActsHelper

  def index
    current_user.ping_page('activity feed')
    @demo = current_user.demo
    @acts = find_requested_acts(@demo)
    @palette = @demo.custom_color_palette

    set_modals_and_intros

    @displayable_categorized_tiles = Tile.displayable_categorized_to_user(current_user, tile_batch_size)

    decide_if_tiles_can_be_done(@displayable_categorized_tiles[:not_completed_tiles])

    if request.xhr?
      render partial: 'shared/more_acts', locals: { acts: @acts }
    end
  end

  private

    def authenticate
      return if authenticate_by_tile_token
      return if authenticate_as_potential_user
      login_as_guest(find_current_board) if params[:public_slug]
      require_login unless current_user
    end

    def find_current_board
      if params[:public_slug]
        @current_board ||= Demo.public_board_by_public_slug(params[:public_slug])
      elsif current_user
        current_user.demo
      end
    end

    def authenticate_by_tile_token
      return false unless params[:tile_token]
      user = User.find_by_id(params[:user_id])
      email_clicked_ping(user)

      if should_authenticate_by_tile_token?(params[:tile_token], user)
        sign_in(user, :remember_user)
        user.move_to_new_demo(params[:demo_id]) if params[:demo_id].present?
        flash[:success] = "Welcome back, #{user.first_name}"
        redirect_to activity_url
      else
        return false
      end
    end

    def should_authenticate_by_tile_token?(tile_token, user)
      user && EmailLink.validate_token(user, tile_token)
    end

    def authenticate_as_potential_user
      return false unless session[:potential_user_id]
      @potential_user = PotentialUser.find_by_id(session[:potential_user_id])

      if @potential_user
        return true
      else
        return false
      end
    end
end
