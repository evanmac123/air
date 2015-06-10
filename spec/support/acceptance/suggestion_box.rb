module SuggestionBox
  def tile_selector
    ".tile_container:not(.placeholder_container) .tile_thumbnail"
  end

  def visible_tiles
    page.all(tile_selector, visible: true)
  end

  def user_submitted_tiles
    selector = tile_selector + ".user_submitted"
    page.all(selector, visible: true)
  end

  def ignored_tiles
    selector = tile_selector + ".ignored"
    page.all(selector, visible: true)
  end

  def suggestion_box_title
    page.find("#suggestion_box_title")
  end

  def draft_title
    page.find("#draft_title")
  end

  def show_thumbnail_buttons
    script = "$('.tile_buttons').css('display', 'block')"
    page.execute_script script
  end

  def submit_tile_selector(tile)
    "a[href *= '#{suggested_tile_path(tile, update_status: Tile::USER_SUBMITTED)}']"  
  end

  def unsubmit_tile_selector(tile)
    "a[href *= '#{suggested_tile_path(tile, update_status: Tile::USER_DRAFT)}']"  
  end

  # submit_tile_button because the name submit_button is taken
  def submit_tile_button tile
    show_thumbnail_buttons
    page.find(submit_tile_selector(tile))
  end

  def unsubmit_button tile
    show_thumbnail_buttons
    page.find(unsubmit_tile_selector(tile))
  end

  def accept_button tile
    show_thumbnail_buttons
    page.find("a[href *= '#{client_admin_tile_path(tile, update_status: Tile::DRAFT)}']")
  end

  def ignore_button tile
    show_thumbnail_buttons
    page.find("a[href *= '#{client_admin_tile_path(tile, update_status: Tile::IGNORED)}']")
  end

  def undo_ignore_button tile
    show_thumbnail_buttons
    page.find("a[href *= '#{client_admin_tile_path(tile, update_status: Tile::USER_SUBMITTED)}']")
  end

  def accept_modal
    page.find("#accept-tile-modal")
  end

  def accept_modal_copy
    "Tile Accepted and Moved to Draft"
  end

  def headline tile
    within tile do
      page.find(".headline .text").text
    end
  end

  def show_more_button
    page.find(".all_draft")
  end
end
