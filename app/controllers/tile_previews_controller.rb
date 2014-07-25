class TilePreviewsController < ApplicationController
  #must_be_authorized_to :client_admin
  #skip_before_filter :authorize
  skip_before_filter :authorize
  before_filter :allow_guest_user

  layout "client_admin_layout"

  def show
    @tile = Tile.viewable_in_public.where(id: params[:id]).first
    @tag = TileTag.where(id: params[:tag]).first

    session[:guest_user] ||= {demo_id: @tile.demo.id}
    #authorize

    schedule_mixpanel_pings @tile
    #current_user.demo ||= @tile.demo
  end

  protected

  def schedule_mixpanel_pings(tile)
    ping "Tile - Viewed in Explore", {tile_id: tile.id}, current_user

    if params[:thumb_click_source]
      ping_action_after_dash params[:thumb_click_source], {tile_id: tile.id}, current_user
    end
  end
end
