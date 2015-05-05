require 'acceptance/acceptance_helper'

feature 'Carousel on Client Admin Tile Page' do
  include TileManagerHelpers
  include WaitForAjax

  let!(:admin) {FactoryGirl.create(:client_admin, share_section_intro_seen: true)}
  let!(:demo)  { admin.demo  }

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  shared_examples_for 'Moves by arrows' do |section, tiles_num, arrow_selector|
    scenario "tiles from #{section} section. moves to the #{arrow_selector} tile", js: true do
      create_tiles_for_sections section => tiles_num
      tiles = demo.send(:"#{section}_tiles").to_a

      i = 0
      offset = arrow_selector == "#next" ? 1 : -1
      visit client_admin_tile_path(tiles[i])
      expect_content tiles[i].headline

      (tiles_num - 1).times do
        i += offset
        page.find(arrow_selector).click
        expect_content tiles[i].headline
      end

      page.find(arrow_selector).click
      expect_content tiles[0].headline
    end
  end

  it_should_behave_like "Moves by arrows", "draft",   3, "#next"
  it_should_behave_like "Moves by arrows", "active",  5, "#next"
  it_should_behave_like "Moves by arrows", "archive", 7, "#next"

  it_should_behave_like "Moves by arrows", "draft",   4, "#prev"
  it_should_behave_like "Moves by arrows", "active",  6, "#prev"
  it_should_behave_like "Moves by arrows", "archive", 2, "#prev"

  it_should_behave_like "Moves by arrows", "draft",   1, "#next"
  it_should_behave_like "Moves by arrows", "active",  1, "#next"
  it_should_behave_like "Moves by arrows", "archive", 1, "#next"

  it_should_behave_like "Moves by arrows", "draft",   1, "#prev"
  it_should_behave_like "Moves by arrows", "active",  1, "#prev"
  it_should_behave_like "Moves by arrows", "archive", 1, "#prev"  
end
