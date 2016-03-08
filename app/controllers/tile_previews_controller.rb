# require Rails.root.join('app/presenters/tile_preview/intros_presenter')

class TilePreviewsController < ApplicationController
  skip_before_filter :authorize
  before_filter :find_tile # must run before authorize_as_guest, so that we can use the tile to implement #find_current_board
  before_filter :authorize_by_explore_token

  before_filter :allow_guest_user
  before_filter :login_as_guest_to_tile_board
  before_filter :authorize_as_guest

  layout "client_admin_layout"

  include LoginByExploreToken
  include ExploreHelper

  def show
    @tile = Tile.viewable_in_public.where(id: params[:id]).first
    @next_tile = Tile.next_public_tile params[:id], 1, params[:tag]
    @prev_tile = Tile.next_public_tile params[:id], -1, params[:tag]
    @tag = TileTag.where(id: params[:tag]).first

    
    if params[:partial_only]
      explore_preview_copy_intro
      render partial: "tile_previews/tile_preview", 
             locals: {tile: @tile, tag: @tag, next_tile: @next_tile, prev_tile: @prev_tile},
             layout: false
    else
      @show_explore_intro = current_user.intros.show_explore_intro!
      explore_preview_copy_intro unless @show_explore_intro
      schedule_mixpanel_pings @tile
      explore_intro_ping @show_explore_intro, params
      render "show", layout: "single_tile_guest_layout" if  logged_in_as_guest?
    end
  end

  protected

  def explore_preview_copy_intro
    @show_explore_preview_copy_intro = current_user.intros.show_explore_preview_copy!
  end

  def schedule_mixpanel_pings(tile)
    ping "Tile - Viewed in Explore", {tile_id: tile.id}, current_user
    ping('Tile - Viewed', {tile_type: "Public Tile - Explore", tile_id: tile.id}, current_user)

    if params[:thumb_click_source]
      ping_action_after_dash params[:thumb_click_source], {tile_id: tile.id}, current_user
    end

    if current_user.present?
      email_clicked_ping(current_user)
    end
  end

  def find_tile
    @tile = Tile.viewable_in_public.where(id: params[:id]).first

    unless @tile
      not_found
      return
    end
  end

  def find_current_board
    @tile.demo
  end

  def login_as_guest_to_tile_board
    if current_user.nil?
      login_as_guest(@tile.demo)
    end
  end

  # def mark_user_voteup_intro_seen!
  #   current_user.voteup_intro_seen = true
  #   current_user.save!
  # end

  # def mark_user_share_link_intro_seen!
  #   current_user.share_link_intro_seen = true
  #   current_user.save!
  # end

  # def create_intros_presenter
  #   show_voteup_intro = current_user && current_user.voteup_intro_never_seen
  #   show_share_link_intro = current_user && current_user.share_link_intro_never_seen

  #   if show_voteup_intro
  #     mark_user_voteup_intro_seen!
  #   end

  #   if !(show_voteup_intro) && show_share_link_intro
  #     mark_user_share_link_intro_seen!
  #   end

  #   # show_voteup_intro = show_share_link_intro = true
  #   TilePreview::IntrosPresenter.new([
  #     ['like-button', "Like a tile? Vote it up to give the creator positive feedback.", show_voteup_intro],
  #     ['share_bar',   "Want to share a tile? Email it using the email icon. Or, share to your social networks using the LinkedIn icon or copying the link.", show_share_link_intro]
  #   ])
  # end

  # def override_public_board_setting
  #   @tile && @tile.is_public && @tile.is_sharable
  # end
end
