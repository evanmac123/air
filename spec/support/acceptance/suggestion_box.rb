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
    thumbnail_action_button tile, Tile::DRAFT
  end

  def ignore_button tile
    thumbnail_action_button tile, Tile::IGNORED
  end

  def undo_ignore_button tile
    thumbnail_action_button tile, Tile::USER_SUBMITTED
  end

  def thumbnail_action_button tile, status
    show_thumbnail_buttons
    page.find("a[href *= '#{status_change_client_admin_tile_path(tile)}'][data-status='#{status}']")
  end

  def headline tile
    within tile do
      page.find(".headline .text").text
    end
  end

  def show_more_button
    page.find(".all_draft")
  end
  #
  # => Manage Access Modal
  #
  def manage_access_link
    page.find(".manage_access")
  end

  def all_users_switcher_on
    page.find("#suggestion_switcher_on")
  end

  def specific_users_switcher_on
    page.find("#suggestion_switcher_off")
  end

  def user_rows
    page.all(".allowed_to_suggest_user")
  end

  def save_button
    page.find("#save_suggestions_access")
  end

  def autocomplete_input
    page.find("#name_substring")
  end

  def fill_in_username_autocomplete(name)
    autocomplete_input.set(name)
    page.execute_script("$('#name_substring').autocomplete('search')")
    wait_for_ajax
  end

  def username_autocomplete_results_click num
    selector = "#name_autocomplete_target li a:first"
    page.execute_script %Q{ $('#{selector}').eq(#{num}).trigger('mouseenter').click() }
  end

  def autocomplete_result_names
    page.all("#name_autocomplete_target li a").map(&:text)
  end

  def warning_modal_mess
    "Are you sure you want to close this form? You haven't saved changes."
  end

  def suggestion_box_header
    "Add people to suggestion box"
  end

  def suggestion_box_cancel
    page.find("#cancel_suggestions_access")
  end

  def warning_cancel
    page.find("#suggestions_access_warning_modal .cancel")
  end

  def warning_confirm
    page.find("#suggestions_access_warning_modal .confirm")
  end
end
