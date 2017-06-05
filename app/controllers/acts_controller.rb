class ActsController < ApplicationController
  include AllowGuestUsersConcern
  include AuthorizePublicBoardsConcern
  include TileBatchHelper
  include ActsHelper

  prepend_before_filter :authenticate

  def index
    @demo ||= current_user.demo
    @acts = find_requested_acts(@demo, params[:per_page] || 5)

    if request.xhr?
      content = render_to_string(
                  partial: "acts/feed",
                  locals: { opts: { acts: @acts } })

      render json: {
        success:   true,
        content:   content,
        lastPage:  @acts.last_page?
      }
    else
      @palette = @demo.custom_color_palette

      set_modals_and_intros

      @displayable_categorized_tiles = Tile.displayable_categorized_to_user(current_user, tile_batch_size)

      decide_if_tiles_can_be_done(@displayable_categorized_tiles[:not_completed_tiles])
    end
  end

  private

    def authenticate
      return true if authenticate_by_tile_token
      return true if authenticate_as_potential_user
      return true if guest_user?
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
      user && user.end_user? && EmailLink.validate_token(user, tile_token)
    end
end
