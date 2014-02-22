require 'acceptance/acceptance_helper'

feature "Client admin copies tile from the explore-preview page" do
  def click_copy
    click_button "Copy to my board"
  end

  before do
    $TESTING_COPYING = true
  end

  after do
    $TESTING_COPYING = false
  end

  scenario "by clicking the proper link" do
    FactoryGirl.create(:multiple_choice_tile, :copyable)
    crank_dj_clear # to resize the images

    admin = FactoryGirl.create(:client_admin)
    visit explore_tile_preview_path(Tile.last, as: admin)

    click_copy
    Tile.count.should == 2
    
    original_tile = Tile.first
    copied_tile = Tile.last

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

    pending "test image_file_name is_public thumbnail_file_name"
  end

  it "should show a helpful message after copying"

  it "should not show the link for a non-copyable tile"

  it "should not show the copy link to logged-in peons"
  it "should show the copy link to logged-in guest users"
  it "should show the copy link if not logged in at all"

end
