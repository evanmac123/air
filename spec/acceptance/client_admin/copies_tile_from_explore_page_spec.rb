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

  scenario "by clicking the proper link" do
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

  it "should do the right thing with the position field (or we should take that out already" do
    target_tile = Tile.last

    click_copy
    visit explore_tile_preview_path(target_tile, as: admin)
    click_copy
    # We should make it to here without an error
  end

  it "should show a helpful message in a modal after copying", js: true do
    click_copy

    expect_content %(You've added this tile to the inactive section of your board. Next, you can edit this tile, go back to "Explore" or go to manage your board.)
  end

  it "should link the edit-this-tile link"
  it "should link the explore link"
  it "should link to board-manage"

  it "should not show the link for a non-copyable tile"
end
