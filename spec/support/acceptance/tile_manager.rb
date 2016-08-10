module TileManagerHelpers
  def tile(tile)
    find(:tile, tile)  # Uses our custom selector (defined in '/support/helpers/tile_helpers.rb')
  end

  def have_reactivate_link_for(tile)
    have_selector("a[data-status='active'][href='#{status_change_client_admin_tile_path(tile)}']")
  end

  def edit_link_for(tile)
    page.find "a[href='#{edit_client_admin_tile_path(tile)}']"
  end

  def have_preview_link_for(tile)
    have_link tile.headline, href: client_admin_tile_path(tile)
  end

  def expect_tile_placeholders(section_id, expected_count)
    page.all("##{section_id} > .placeholder_container:not(.creation_placeholder)", visible: true).count.should == expected_count
  end

  def expect_inactive_tile_placeholders(expected_count)
    expect_tile_placeholders("archive", expected_count)
  end

  def expect_active_tile_placeholders(expected_count)
    expect_tile_placeholders("active", expected_count)
  end

  def expect_draft_tile_placeholders(expected_count)
    expect_tile_placeholders("draft", expected_count)
  end

  def expect_page_to_be_locked
    page.should have_css('.fa-lock', visible: true)
    page.should have_content("Please create and post at least one tile to unlock this page.")
    page.should have_link 'Go to Tiles Page', client_admin_tiles_path
  end

  def expect_link_to_have_lock_icon(container)
    within(container) do
      page.should have_css('.fa-lock', visible: true)
    end
  end

  def visit_tile_manager_page
    visit tile_manager_page
  end

  def create_tiles_for_sections params
    params["archived"] = params.delete("archive") if params["archive"]

    params.each do |section, number|
      (1..number).to_a.map do |i|
        FactoryGirl.create(
          :multiple_choice_tile,
          section.to_sym,
          demo: demo,
          headline: "Tile #{section.capitalize} #{i}"
        )
      end
    end
  end

  def move_tile tile1, tile2
    selected_tile = tile(tile1)
    new_place_tile = tile(tile2)
    selected_tile.drag_to new_place_tile
  end

  def move_tile_between_sections(tile1, tile2)
    selected_tile = tile(tile1)
    new_place_tile = tile(tile2)
    selected_tile.drag_to(new_place_tile)
    wait_for_ajax
    move_tile(tile1, tile2)
  end
end
