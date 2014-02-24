require 'acceptance/acceptance_helper'

feature "Client admin copies tile from the explore-preview page" do
  def click_copy
    click_button "Copy to my board"
  end

  let (:admin) {a_client_admin}
  let (:original_tile) { FactoryGirl.create(:multiple_choice_tile, :copyable) }

  before do
    $TESTING_COPYING = true

    visit explore_tile_preview_path(original_tile, as: admin)
    crank_dj_clear # to resize the images
  end

  after do
    $TESTING_COPYING = false
  end

  def newest_tile
    Tile.order("created_at DESC").first
  end

  scenario "by clicking the proper link", js: true do
    click_copy
    Tile.count.should == 2
    
    copied_tile = Tile.order("created_at DESC").first

    %w(correct_answer_index headline image_content_type image_file_size image_meta link_address multiple_choice_answers points question supporting_content thumbnail_content_type thumbnail_file_size thumbnail_meta type).each do |expected_same_field|
      copied_tile[expected_same_field].should == original_tile[expected_same_field]
    end

    copied_tile.status.should == Tile::ARCHIVE
    copied_tile.demo_id.should == admin.demo_id
    copied_tile.is_copyable.should be_false
    copied_tile.is_public.should be_false

    copied_tile.image_processing.should be_false
    copied_tile.thumbnail_processing.should be_false
    copied_tile.image_updated_at.should be_present
    copied_tile.thumbnail_updated_at.should be_present
    copied_tile.image_file_name.should == original_tile.image_file_name
    copied_tile.thumbnail_file_name.should == original_tile.thumbnail_file_name
  end

  it "should show a helpful message in a modal after copying", js: true do
    click_copy
    page.find('#tile_copied_lightbox', visible: true)

    expect_content %(You've added this tile to the inactive section of your board. Next, you can edit this tile, go back to "Explore" or go to manage your board.)
  end

  it "should link the edit-this-tile link in the modal after copying", js: true do
    click_copy
    page.find('#tile_copied_lightbox', visible: true)

    within('#tile_copied_lightbox') do
      click_link "edit this tile"
      should_be_on edit_client_admin_tile_path(newest_tile)
    end
  end

  it "should link the explore link in the modal after copying", js: true do
    click_copy
    page.find('#tile_copied_lightbox', visible: true)

    within('#tile_copied_lightbox') do
      click_link "go back to \"Explore\""
      should_be_on client_admin_explore_path
    end
  end

  it "should link to board-manage in the modal after copying", js: true do
    click_copy
    page.find('#tile_copied_lightbox', visible: true)

    within('#tile_copied_lightbox') do
      click_link "manage your board"
      should_be_on client_admin_tiles_path
    end
  end

  it "should not show the link for a non-copyable tile" do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)
    visit explore_tile_preview_path(tile, as: admin)
    page.should_not have_content("Copy to my board")
  end
end
