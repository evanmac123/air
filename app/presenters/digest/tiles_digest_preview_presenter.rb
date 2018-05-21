# frozen_string_literal: true

class TilesDigestPreviewPresenter < TilesDigestPresenter
  def initialize(user, demo)
    @user = user
    @demo = demo
  end

  def link_options
    { target: "_blank" }
  end

  def tiles
    demo.digest_tiles.segmented_for_user(@user)
  end

  def email_heading
    STANDARD_DIGEST_HEADING
  end

  def general_site_url(tile_id: nil)
    client_admin_tiles_path(params: { tile_id: tile_id, section: Tile::DRAFT }, anchor: "tab-active")
  end
end
