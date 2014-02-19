class ExploresController < ApplicationController
  skip_before_filter :authorize
  layout :choose_layout

  def show
    @tiles = Tile.viewable_in_public.order("created_at DESC")
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
