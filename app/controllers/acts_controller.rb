class ActsController < ApplicationController
  include TileBatchHelper
  include ActsHelper

  prepend_before_filter :allow_guest_user_if_public

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

    def find_current_board
      if params[:public_slug]
        @current_board ||= Demo.public_board_by_public_slug(params[:public_slug])
      elsif current_user
        current_user.demo
      end
    end
end
