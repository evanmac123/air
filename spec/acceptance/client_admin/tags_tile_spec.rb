require 'acceptance/acceptance_helper'

feature 'Tags tile' do
  before do
    $rollout.activate(:public_tile)
    @client_admin = FactoryGirl.create(:client_admin)
  end

  def select_tile_tag(tag_title)
    fill_in 'add-tag', with: tag_title
    select tag_title, from: "Tag with:"
  end

  def select_add_new
    select_tile_tag "Add new..."
  end

  def expect_no_tiles(tag)
    tag.tiles.reload.should be_empty
  end

  def enter_new_title(title)
    fill_in "New tag", with: title
  end
  
  def click_save_tag_button
    click_button "Save new tag"  
  end

  def click_update_tile_button
    click_button "Update tile"  
  end

  it "creating a tile with an existing tag", js: true do
    tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    visit new_client_admin_tile_path(as: @client_admin)
    fill_in_valid_form_entries

    click_make_public
    select_tile_tag "Cheese"
    click_create_tile_button

    page.should have_content(after_tile_save_message)

    tag.tiles.reload.should include(Tile.last)
  end

  it "creating a tile with a new tag", js: true do
    visit new_client_admin_tile_path(as: @client_admin)
    fill_in_valid_form_entries

    select_add_new
    enter_new_title "Awesomeness"
    click_save_tag_button
    click_create_tile_button

    page.should have_content(after_tile_save_message)

    tag = TileTag.find_by_title("Awesomeness")
    tag.tiles.should include(Tile.last)
  end

  it "shows the current tag when going to an existing, tagged tile" do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    tile.tile_tags << tag

    visit edit_client_admin_tile_path(tile, as: @client_admin)
    page.find("#tile_tag_select").value.should == tag.id.to_s
  end

  it "editing an existing, untagged tile with an existing tag", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    
    visit edit_client_admin_tile_path(tile, as: @client_admin)
    select_tile_tag "Cheese"
    click_button "Update tile"

    tag.tiles.reload.should include(Tile.last)
  end

  it "editing an existing, tagged tile with an existing tag", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    first_tag = FactoryGirl.create(:tile_tag, title: "Cheese")
    second_tag = FactoryGirl.create(:tile_tag, title: "Ducks")
    tile.tile_tags = [first_tag]
   
    visit edit_client_admin_tile_path(tile, as: @client_admin)
    select_tile_tag "Ducks"
    click_update_tile_button

    expect_no_tiles first_tag
    second_tag.tiles.reload.should include(tile)
  end

  it "editing a tile with a new tag", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    visit edit_client_admin_tile_path(tile, as: @client_admin)
    fill_in_valid_form_entries

    select_add_new
    enter_new_title "Cheezwhiz"
    click_save_tag_button

    click_update_tile_button

    tag = TileTag.find_by_title("Cheezwhiz")
    tag.tiles.should include(tile)
  end

  it "allows tag to be removed", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
    tile.tile_tags = [FactoryGirl.create(:tile_tag)]

    visit edit_client_admin_tile_path(tile, as: @client_admin)
    select "", from: "Tag with:"
    click_update_tile_button

    tile.reload.tile_tags.should be_empty
  end

  it "normalizes tag names so they look consistent", js: true do
    visit new_client_admin_tile_path(as: @client_admin)
    fill_in_valid_form_entries

    select_add_new
    enter_new_title "   i   am     dumb        "
    click_save_tag_button

    TileTag.last.title.should == "I am dumb"
  end

  it "does not let a duplicate tag be created", js: true do
    tag = FactoryGirl.create(:tile_tag, title: "Taken")
    visit new_client_admin_tile_path(as: @client_admin)

    select_add_new
    enter_new_title "Taken"
    click_save_tag_button

    TileTag.all.should have(1).tag
    page.find("#tile_tag_select").value.should == tag.id.to_s
  end
end
