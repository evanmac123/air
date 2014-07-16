require 'acceptance/acceptance_helper'

feature 'Tags tile' do
  before do
    @client_admin = FactoryGirl.create(:client_admin)
  end

  def expect_no_tiles(tag)
    tag.tiles.reload.should be_empty
  end

  def click_update_tile_button
    click_button "Update tile"  
  end

  it "creating a tile with an existing tag", js: true do
    tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    visit new_client_admin_tile_path(as: @client_admin)
    fill_in_valid_form_entries

    click_make_public
    add_tile_tag "Cheese"
    click_create_button

    page.should have_content(after_tile_save_message)

    tag.tiles.reload.should include(Tile.last)
  end

  it "creating a tile with a new tag", js: true do
    visit new_client_admin_tile_path(as: @client_admin)
    fill_in_valid_form_entries

    click_make_public
    add_new_tile_tag "Awesomeness"
    click_create_button

    page.should have_content(after_tile_save_message)

    tag = TileTag.find_by_title("Awesomeness")
    tag.tiles.should include(Tile.last)
  end

  it "shows the current tag when going to an existing, tagged tile", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    tile.tile_taggings.create!(tile_tag: tag)

    visit edit_client_admin_tile_path(tile, as: @client_admin)
    find('.tile_tags > li').text.should eq tag.title
  end

  it "editing an existing, untagged tile with an existing tag", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    
    visit edit_client_admin_tile_path(tile, as: @client_admin)
    click_make_public
    add_tile_tag "Cheese"
    click_button "Update tile"

    tag.tiles.reload.should include(Tile.last)
  end

  it "editing an existing, tagged tile with an existing tag", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public, demo: @client_admin.demo)
    first_tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    second_tag = FactoryGirl.create(:tile_tag, title: "Ducks")
    tile.tile_taggings.create!(tile_tag: first_tag)
   
    visit edit_client_admin_tile_path(tile, as: @client_admin)
    
    #remove existing tile tags
    find('.tile_tags > li:first > .fa-times').click()
    #remove existing tile tags
    find('.tile_tags > li > .fa-times').click()

    add_tile_tag "Ducks"
    
    click_update_tile_button

    expect_no_tiles first_tag
    second_tag.tiles.reload.should include(tile)
  end

  it "editing a tile with a new tag", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    visit edit_client_admin_tile_path(tile, as: @client_admin)
    
    fill_in_valid_form_entries({tile_tag_title: "Cheezwhiz"}, true)

    click_update_tile_button

    tag = TileTag.find_by_title("Cheezwhiz")
    tag.tiles.should include(tile)
  end

  it "allows tag to be removed", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public, demo: @client_admin.demo)

    visit edit_client_admin_tile_path(tile, as: @client_admin)
    
    find('.tile_tags > li > .fa-times').click
    click_make_nonpublic

    click_update_tile_button

    tile.reload.tile_tags.should be_empty
  end

  it "normalizes tag names so they look consistent", js: true do
    visit new_client_admin_tile_path(as: @client_admin)
    fill_in_valid_form_entries({tile_tag_title: "   i   am     dumb        "}, true)
    find('.tile_tags > li > .fa-times')
    click_create_button
    TileTag.last.title.should eq "i am dumb"
  end

  it "does not let a duplicate tag be created", js: true do
    tag = FactoryGirl.create(:tile_tag, title: "Taken")
    visit new_client_admin_tile_path(as: @client_admin)
    fill_in_valid_form_entries

    click_make_public
    add_tile_tag "Taken"
    click_create_button
    TileTag.all.should have(1).tag
  end
end
