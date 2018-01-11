module TileManagerHelpers
  def tile_from_thumbnail(tile)
    find(".tile_thumbnail[data-tile-id='#{tile.id}']")
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
    expect(page.all("##{section_id} > .placeholder_container:not(.creation_placeholder)", visible: true).count).to eq(expected_count)
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
    expect(page).to have_css('.fa-lock', visible: true)
    expect(page).to have_content("Please create and post at least one tile to unlock this page.")
    expect(page).to have_link 'Go to Tiles Page', client_admin_tiles_path
  end

  def expect_link_to_have_lock_icon(container)
    within(container) do
      expect(page).to have_css('.fa-lock', visible: true)
    end
  end

  def visit_tile_manager_page
    visit tile_manager_page
  end

  def create_tiles_for_sections params
    params["archived"] = params.delete("archive") if params["archive"]

    params.each do |section, number|
      (1..number).to_a.map do |i|
        FactoryBot.create(
          :multiple_choice_tile,
          section.to_sym,
          demo: demo,
          headline: "Tile #{section.capitalize} #{i}"
        )
      end
    end
  end

  def move_tile(tile1, tile2)
    selected_tile = tile_from_thumbnail(tile1)
    new_place_tile = tile_from_thumbnail(tile2)
    selected_tile.drag_to new_place_tile
  end
end
