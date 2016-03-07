require 'acceptance/acceptance_helper'

feature "interacts with a tile from the explore-preview page" do
  include GuestUserConversionHelpers
  include WaitForAjax
  include SignUpModalHelpers
  include TilePreviewHelpers

  def show_register_form? # for SignUpModalHelpers
    @user.nil? || !(@user.is_client_admin || @user.is_site_admin)
  end

  let (:creator) {FactoryGirl.create(:client_admin, name: "Charlotte McTilecreator")}
  let (:actor) {FactoryGirl.create(:client_admin, name: "Joe Copier")}
  let (:last_actor) {FactoryGirl.create(:client_admin, name: "John Lastactor")}
  let (:second_actor) {FactoryGirl.create(:client_admin, name: "Suzanne von Secondactor")}

  before do
   pending
  end

  shared_examples_for 'copies/likes tile' do
    scenario "by clicking the proper link", js: true do
      
      click_copy_button
   
      crank_dj_clear
      Tile.count.should == 2
      expect_tile_copied(@original_tile, @user)
    end

    context "when the tile has no creator", js: true do
      before do
        @original_tile.update_attributes(creator: nil)
        
      end

      it "should work", js: true do
        click_copy_button
     
        crank_dj_clear
        Tile.count.should == 2
        expect_tile_copied(@original_tile, @user)
      end
    end

    scenario "should show a helpful message in a modal after copying", js: true do
      
      click_copy_button
      page.find('.tile_copied_lightbox', visible: true)

      expect_content post_copy_copy
    end

    scenario "works if no creator is set", js: true do
      
      @original_tile.update_attributes(creator: nil)
      click_copy_button
      page.find('.tile_copied_lightbox', visible: true)

      expect_content post_copy_copy
    end

    scenario "should ping", js: true do
      
      crank_dj_clear
      FakeMixpanelTracker.clear_tracked_events

      click_copy_button
      crank_dj_clear
      
      FakeMixpanelTracker.should have_event_matching('Explore page - Interaction', {
          tile_id: @original_tile.id,
          action: 'Clicked Copy',
          page: "Large Tile View"
        })
    end

    scenario "should record user who copied", js: true do
      
      click_copy_button
    
      @original_tile.user_tile_copies.reload.first.user_id.should eq @user.id
    end
  
    scenario "should not show the link for a non-copyable tile", js: true do
      
      tile = FactoryGirl.create(:multiple_choice_tile, :public)
      visit explore_tile_preview_path(tile, as: @user)
      page.should have_content("View Only")
    end
  end

  shared_examples_for 'gets registration form after closing intro' do |name, selector|
    scenario "when clicks #{name}", js: true do
      
      page.find(selector).click
      register_if_guest
    end
  end

  shared_examples_for "has intro modals" do
    scenario "they see upvote intro on the first visit", js: true do
      page.should have_content(upvote_tutorial_content)
    end

    scenario "they don't see upvote intro on subsequent visits", js: true do
      visit @path
      page.should have_no_content(upvote_tutorial_content)
    end

    scenario "they see share link intro after upvote", js: true do
      page.should have_content(upvote_tutorial_content)
      click_next_intro_link
      page.should have_content(share_link_tutorial_content)
    end

    scenario "they see no modals on second visit if they saw both the first time", js: true do
      page.should have_content(upvote_tutorial_content)
      click_next_intro_link
      page.should have_content(share_link_tutorial_content)
      wait_for_ajax

      visit @path
      page.should have_no_content(share_link_tutorial_content)
    end

    scenario "they see share link intro on second visit if not yet seen", js: true do
      visit @path
      page.should have_content(share_link_tutorial_content)
    end

    scenario "they don't see share link intro on third visit", js: true do
      visit @path
      visit @path
      page.should have_no_content(share_link_tutorial_content)
    end
  end

  shared_examples_for 'uses share tile link' do
    before(:each) do
      
    end

    scenario "ping when click linkedin icon", js: true do
      page.find('.share_linkedin').click            
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      properties = {"action" => 'Clicked share tile via LinkedIn', "tile_id" => @original_tile.id.to_s}
      FakeMixpanelTracker.should have_event_matching('Explore page - Interaction', properties)
    end

    scenario "ping when click linkedin icon", js: true do
      page.find('.share_mail').click            
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      properties = {"action" => 'Clicked share tile via email', "tile_id" => @original_tile.id.to_s}
      FakeMixpanelTracker.should have_event_matching('Explore page - Interaction', properties)
    end

    scenario "should be without protocol", js: true do
      uri = URI.parse(current_url)
      page.find('#share_link').value.should == "#{uri.host}:#{uri.port}#{uri.path}".gsub(/^www./, "")  
    end
  end

  context "as Client admin" do
    before do
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)
      crank_dj_clear # to resize the images
      @original_tile.reload

      @user = FactoryGirl.create(:client_admin, name: "Lucille Adminsky")
      visit explore_tile_preview_path(@original_tile, as: @user)
    end

    it_should_behave_like "copies/likes tile"
    it_should_behave_like 'uses share tile link'

    scenario "unliking a tile that was liked sometime in the past updates the page properly", js: true do
      tile = @original_tile
      client_admin = @user
      UserTileLike.create!(tile: tile, user: client_admin) # we liked this at some point in the past

      visit explore_path(as: client_admin)    
      click_tile
      page.find(:xpath,"//span[contains(@class, 'like_message')]/div[@id='like_value']").should have_content("1")
      
      click_unlike_link_in_preview
      page.find(:xpath,"//span[contains(@class, 'like_message')]/div[@id='like_value']").should_not be_visible
    end
  end

  context "as Nobody" do
    before do
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)
      crank_dj_clear # to resize the images
      @original_tile.reload

      @user = nil
      visit explore_tile_preview_path(@original_tile, as: @user)
    end

    it_should_behave_like "copies/likes tile"
    it_should_behave_like 'uses share tile link'
    it_should_behave_like "gets registration form after closing intro", "like button", ".not_like_button"
    it_should_behave_like "gets registration form after closing intro", "copy button", "a .copy_button"
    it_should_behave_like "gets registration form after closing intro", "random link", "#random-tile-link"
    it_should_behave_like "gets registration form after closing intro", "back link", "#back-link"
    it_should_behave_like "gets registration form after closing intro", "tag link", ".tag a"
    it_should_behave_like "gets registration form after closing intro", "right arrow", "#next"
    it_should_behave_like "gets registration form after closing intro", "left arrow", "#prev"
    it_should_behave_like "gets registration form after closing intro", "logo", "#logo"

    it "should not see the voteup intro" do
      page.should have_no_content(upvote_tutorial_content)
    end
  end

  context "as Guest" do
    before do
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)
      crank_dj_clear # to resize the images
      @original_tile.reload

      @user = FactoryGirl.create(:guest_user)
      @path = explore_tile_preview_path(@original_tile, as: @user)
      visit @path
    end

    it_should_behave_like "copies/likes tile"
    it_should_behave_like 'uses share tile link'
    it_should_behave_like "gets registration form after closing intro", "like button", ".not_like_button"
    it_should_behave_like "gets registration form after closing intro", "copy button", "a .copy_button"
    it_should_behave_like "gets registration form after closing intro", "random link", "#random-tile-link"
    it_should_behave_like "gets registration form after closing intro", "back link", "#back-link"
    it_should_behave_like "gets registration form after closing intro", "tag link", ".tag a"
    it_should_behave_like "gets registration form after closing intro", "right arrow", "#next"
    it_should_behave_like "gets registration form after closing intro", "left arrow", "#prev"
    it_should_behave_like "gets registration form after closing intro", "logo", "#logo"
    it_should_behave_like "has intro modals"
  end

  context "as User" do
    before do
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)
      crank_dj_clear # to resize the images
      @original_tile.reload

      @user = FactoryGirl.create(:claimed_user)
      @path = explore_tile_preview_path(@original_tile, as: @user)
      visit @path
    end

    it_should_behave_like "copies/likes tile"
    it_should_behave_like 'uses share tile link'
    it_should_behave_like "gets registration form after closing intro", "like button", ".not_like_button"
    it_should_behave_like "gets registration form after closing intro", "copy button", "a .copy_button"
    it_should_behave_like "gets registration form after closing intro", "random link", "#random-tile-link"
    it_should_behave_like "gets registration form after closing intro", "back link", "#back-link"
    it_should_behave_like "gets registration form after closing intro", "tag link", ".tag a"
    it_should_behave_like "gets registration form after closing intro", "right arrow", "#next"
    it_should_behave_like "gets registration form after closing intro", "left arrow", "#prev"
    it_should_behave_like "gets registration form after closing intro", "logo", "#logo"
    it_should_behave_like "has intro modals"
  end

  context "as guest for a public tile in a private board" do
    it "should allow the guest to see the tile" do
      private_board = FactoryGirl.create(:demo, is_public: false)
      tile = FactoryGirl.create(:sharable_and_public_tile, demo: private_board)      
      visit explore_tile_preview_path(tile)

      expect_no_content "This board is currently private"
      expect_content tile.headline
    end
  end
end
