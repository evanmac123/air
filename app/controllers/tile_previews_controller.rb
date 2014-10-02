require Rails.root.join('app/presenters/tile_previews_intros_presenter')

class TilePreviewsController < ApplicationController
  skip_before_filter :authorize
  before_filter :find_tile # must run before authorize_as_guest, so that we can use the tile to implement #find_current_board
  before_filter :authorize_by_explore_token

  before_filter :allow_guest_user
  before_filter :login_as_guest_to_tile_board
  before_filter :authorize_as_guest

  layout "client_admin_layout"

  include LoginByExploreToken

  def show
    tile_viewed_ping
    if params[:partial_only]
      show_partial
    else
      @tile = Tile.viewable_in_public.where(id: params[:id]).first
      @tag = TileTag.where(id: params[:tag]).first

      @intros = create_intros_presenter
      schedule_mixpanel_pings @tile
    end
  end

  protected

  def show_partial
    tag = TileTag.where(id: params[:tag]).first
    next_tile = Tile.next_public_tile params[:id], params[:offset].to_i, params[:tag]

    render json: {
      tile_id:      next_tile.id,
      tile_content: render_to_string(partial: "tile_previews/tile_preview", locals: { tile: next_tile, tag: tag })
    }
    ping_on_arrow params[:offset].to_i
    return
  end

  def ping_on_arrow offset
    action = offset > 0 ? "Clicked arrow to next tile" : "Clicked arrow to previous tile"
    ping "Explore page - Interaction", {action: action}, current_user
  end

  def schedule_mixpanel_pings(tile)
    ping "Tile - Viewed in Explore", {tile_id: tile.id}, current_user

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

  def mark_user_voteup_intro_seen!
    current_user.voteup_intro_seen = true
    current_user.save!
  end

  def mark_user_share_link_intro_seen!
    current_user.share_link_intro_seen = true
    current_user.save!
  end

  def create_intros_presenter
    show_voteup_intro = current_user && current_user.voteup_intro_never_seen
    show_share_link_intro = current_user && current_user.share_link_intro_never_seen

    if show_voteup_intro
      mark_user_voteup_intro_seen!
    end

    if !(show_voteup_intro) && show_share_link_intro
      mark_user_share_link_intro_seen!
    end

    TilePreviewIntrosPresenter.new([
      ['like-button', "Like a tile? Vote it up to give the creator positive feedback.", show_voteup_intro],
      ['share_bar',   "Want to share a tile? Email it using the email icon. Or, share to your social networks using the LinkedIn icon or copying the link.", show_share_link_intro]
    ])
  end

  def tile_viewed_ping
    ping('Tile Viewed', {tile_type: "Public Tile - Explore"}, current_user)
  end
end
