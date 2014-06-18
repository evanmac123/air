require 'acceptance/acceptance_helper'

feature "Client admin copies/likes tile from the explore-preview page" do
  def expect_copied_lightbox
    page.should have_content(post_copy_copy)
  end

  def click_copy_button
    page.find('#copy_tile_button').click
    expect_copied_lightbox
    page.find('#close_tile_copied_lightbox').click
  end

  def click_copy_link
    page.first('.copy_tile_link').click
    expect_copied_lightbox
  end
 
  def click_like
    first('.not_like_button').click
  end

  def click_unlike_link_in_preview
    page.find(:xpath,"//div[contains(@class,'like-button')]/a[2]").click
  end

    def click_unlike_link
    page.first('.tile_liked a').click
  end

  def newest_tile
    Tile.order("created_at DESC").first
  end

  def click_tile
    page.find(:xpath,"//div[contains(@class,'tile_image')]/a").click
  end

  def expect_tile_copied(original_tile, copying_user)
    copied_tile = newest_tile

    Tile.count.should == 2
    %w(correct_answer_index headline image_content_type image_file_size image_meta link_address multiple_choice_answers points question supporting_content thumbnail_content_type thumbnail_file_size thumbnail_meta type).each do |expected_same_field|
      copied_tile[expected_same_field].should == original_tile[expected_same_field]
    end

    copied_tile.creator.should == copying_user
    copied_tile.status.should == Tile::DRAFT
    copied_tile.demo_id.should == admin.demo_id
    copied_tile.is_copyable.should be_false
    copied_tile.is_public.should be_false

    #copied_tile.image_processing.should be_false
    #copied_tile.thumbnail_processing.should be_false
    copied_tile.image_updated_at.should be_present
    copied_tile.thumbnail_updated_at.should be_present
    copied_tile.image_file_name.should == original_tile.image_file_name
    copied_tile.thumbnail_file_name.should == original_tile.thumbnail_file_name
  end

  let (:admin) {FactoryGirl.create(:client_admin, name: "Lucille Adminsky")}
  let (:creator) {FactoryGirl.create(:client_admin, name: "Charlotte McTilecreator")}
  let (:actor) {FactoryGirl.create(:client_admin, name: "Joe Copier")}
  let (:last_actor) {FactoryGirl.create(:client_admin, name: "John Lastactor")}
  let (:second_actor) {FactoryGirl.create(:client_admin, name: "Suzanne von Secondactor")}
  
  context 'Admin copies/likes tile' do
    before do
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)

      crank_dj_clear # to resize the images
      @original_tile.reload

      visit explore_tile_preview_path(@original_tile, as: admin)
    end
    
    scenario "by clicking the proper link", js: true do
      click_copy_button
   
      crank_dj_clear
      expect_tile_copied(@original_tile, admin)
    end

    context "when the tile has no creator", js: true do
      before do
        @original_tile.update_attributes(creator: nil)
      end

      it "should work", js: true do
        click_copy_button
     
        crank_dj_clear
        expect_tile_copied(@original_tile, admin)
      end
    end

    scenario "should show a helpful message in a modal after copying", js: true do
      click_copy_button
      page.find('#tile_copied_lightbox', visible: true)

      expect_content post_copy_copy
    end

    scenario "works if no creator is set", js: true do
      @original_tile.update_attributes(creator: nil)
      click_copy_button
      page.find('#tile_copied_lightbox', visible: true)

      expect_content post_copy_copy
    end

    scenario "should ping", js: true do
      crank_dj_clear
      FakeMixpanelTracker.clear_tracked_events

      click_copy_button
      crank_dj_clear

      FakeMixpanelTracker.should have_event_matching('Explore page - Large Tile View', {
          tile_id: @original_tile.id,
          action: 'Clicked Copy'
        })
    end

    scenario "should record user who copied", js: true do
      click_copy_button
    
      @original_tile.user_tile_copies.reload.first.user_id.should eq admin.id
    end
  
    scenario "should not show the link for a non-copyable tile", js: true do
      tile = FactoryGirl.create(:multiple_choice_tile, :public)
      visit explore_tile_preview_path(tile, as: admin)
      page.should have_content("View Only")
    end

    scenario "has credit for the original creator if present", js: true do
      original_board = FactoryGirl.create(:demo, name: "Smits and O'Houlihan")
      creator = FactoryGirl.create(:user, name: "Jimmy O'Houlihan", demo: original_board)

      @original_tile.creator = creator
      @original_tile.created_at = Chronic.parse("May 1, 2013, 12:00")
      @original_tile.save!

      click_copy_button

      # little hack
      newest_tile.update_attributes(status: Tile::ACTIVE)
      visit tiles_path(start_tile: newest_tile.id)
      expect_content "Jimmy O'Houlihan, Smits and O'Houlihan"
      expect_content "May 1, 2013"
    end
  end

  scenario "unliking a tile that was liked sometime in the past updates the page properly", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)
    client_admin = a_client_admin
    UserTileLike.create!(tile: tile, user: client_admin) # we liked this at some point in the past

    visit explore_path(as: client_admin)    
    click_tile
    page.find(:xpath,"//span[contains(@class, 'like_message')]/div[@id='like_value']").should have_content("1")
    click_unlike_link_in_preview
    page.find(:xpath,"//span[contains(@class, 'like_message')]/div[@id='like_value']").should_not be_visible
  end
end
