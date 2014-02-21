class TilePreviewsController < ApplicationController
  skip_before_filter :authorize
  layout :choose_layout_depending_on_logged_in_or_not

  def show
    @tile = Tile.viewable_in_public.where(id: params[:id]).first
  end
end
