require 'acceptance/acceptance_helper'

feature 'Tags tile' do
  include WaitForAjax

  before do
    pending
    @client_admin = FactoryGirl.create(:client_admin)
  end

  def expect_no_tiles(tag)
    tag.tiles.reload.should be_empty
  end

  it "shows the current tag when going to tagged tile", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo, is_sharable: true)
    tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    tile.tile_taggings.create!(tile_tag: tag)

    visit client_admin_tile_path(tile, as: @client_admin)
    find('.tile_tags > li').text.should eq tag.title
  end

  it "editing untagged tile with an existing tag", js: true, driver: :webkit do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo, is_sharable: true)
    tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    
    visit client_admin_tile_path(tile, as: @client_admin)
    open_public_section
    add_tile_tag "Cheese"

    wait_for_ajax
    tag.tiles.reload.should include(Tile.last)
  end

  it "editing tagged tile with an existing tag", js: true, driver: :webkit do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    first_tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    second_tag = FactoryGirl.create(:tile_tag, title: "Ducks")
    tile.tile_taggings.create!(tile_tag: first_tag)
   
    visit client_admin_tile_path(tile, as: @client_admin)
    open_public_section
    #remove existing tile tags
    find('.tile_tags > li > .fa-times').click()

    add_tile_tag "Ducks"

    wait_for_ajax
    expect_no_tiles first_tag
    second_tag.tiles.reload.should include(tile)
  end

  it "editing a tile with a new tag", js: true, driver: :webkit do
    tile = FactoryGirl.create(:multiple_choice_tile, :public, demo: @client_admin.demo)
    visit client_admin_tile_path(tile, as: @client_admin)

    add_new_tile_tag "Cheezwhiz"

    wait_for_ajax
    tag = TileTag.find_by_title("Cheezwhiz")
    tag.tiles.should include(tile)
  end

  it "normalizes tag names so they look consistent", js: true, driver: :webkit do
    tile = FactoryGirl.create(:multiple_choice_tile, :public, demo: @client_admin.demo)
    visit client_admin_tile_path(tile, as: @client_admin)

    add_new_tile_tag "   i   am     dumb        "

    wait_for_ajax
    TileTag.last.title.should eq "i am dumb"
  end

  it "does not let a duplicate tag be created", js: true, driver: :webkit do
    tag = FactoryGirl.create(:tile_tag, title: "Taken")
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    visit client_admin_tile_path(tile, as: @client_admin)

    open_public_section
    add_tile_tag "Taken"

    wait_for_ajax
    TileTag.all.should have(1).tag
  end
end
