class ExploresController < ApplicationController
  include TileBatchHelper

  skip_before_filter :authorize
  layout :choose_layout

  def show
    @tiles = Tile.viewable_in_public.order("created_at DESC").limit(tile_batch_size)

    if params[:partial_only]
      render partial: "shared/tile_wall", locals: {tiles: @tiles, path_for_more_tiles: explore_path}
    end
  end

  protected

  def choose_layout
    if current_user
      "application"
    else
      "external"
    end
  end
end
