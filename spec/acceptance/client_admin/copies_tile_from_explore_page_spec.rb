require 'acceptance/acceptance_helper'

feature "Client admin copies tile from the explore-preview page" do
  def click_copy
    click_button "Copy to my board"
    page.should have_content("You've added this tile to the inactive section of your board.")
  end

  let (:admin) {a_client_admin}

  before do
    @original_tile = FactoryGirl.create(:multiple_choice_tile, :public, :copyable)

    crank_dj_clear # to resize the images
    @original_tile.reload

    visit explore_tile_preview_path(@original_tile, as: admin)
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
   
    crank_dj_clear
    copied_tile = Tile.order("created_at DESC").first

    %w(correct_answer_index headline image_content_type image_file_size image_meta link_address multiple_choice_answers points question supporting_content thumbnail_content_type thumbnail_file_size thumbnail_meta type).each do |expected_same_field|
      copied_tile[expected_same_field].should == @original_tile[expected_same_field]
    end

    copied_tile.status.should == Tile::DRAFT
    copied_tile.demo_id.should == admin.demo_id
    copied_tile.is_copyable.should be_false
    copied_tile.is_public.should be_false

    copied_tile.image_processing.should be_false
    copied_tile.thumbnail_processing.should be_false
    copied_tile.image_updated_at.should be_present
    copied_tile.thumbnail_updated_at.should be_present
    copied_tile.image_file_name.should == @original_tile.image_file_name
    copied_tile.thumbnail_file_name.should == @original_tile.thumbnail_file_name
  end

  it "should show a helpful message in a modal after copying", js: true do
    click_copy
    page.find('#tile_copied_lightbox', visible: true)

    expect_content %(You've added this tile to the inactive section of your board. Next, you can edit this tile, go back to "Explore" or go to manage your board.)
  end

  it "should ping", js: true do
    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    click_copy
    crank_dj_clear

    FakeMixpanelTracker.should have_event_matching('Tile - Copied', {tile_id: @original_tile.id})
  end

  it "should not show the link for a non-copyable tile" do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)
    visit explore_tile_preview_path(tile, as: admin)
    page.should_not have_content("Copy to my board")
  end

  it "has credit for the original creator if present", js: true do
    original_board = FactoryGirl.create(:demo, name: "Smits and O'Houlihan")
    creator = FactoryGirl.create(:user, name: "Jimmy O'Houlihan", demo: original_board)

    @original_tile.creator = creator
    @original_tile.created_at = Chronic.parse("May 1, 2013, 12:00")
    @original_tile.save!

    click_copy

    # little hack
    newest_tile.update_attributes(status: Tile::ACTIVE)
    visit tiles_path(start_tile: newest_tile.id)
    expect_content "Jimmy O'Houlihan, Smits and O'Houlihan"
    expect_content "May 1, 2013"
  end
end
