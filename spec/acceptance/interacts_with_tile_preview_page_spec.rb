require 'acceptance/acceptance_helper'

feature "interacts with a tile from the explore-preview page" do
  include GuestUserConversionHelpers
  include WaitForAjax

  def expect_copied_lightbox
    page.should have_content(post_copy_copy)
  end

  def click_copy_button
    page.find('#copy_tile_button').click
    register_if_guest
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
    copied_tile.demo_id.should == @user.demo_id
    copied_tile.is_copyable.should be_false
    copied_tile.is_public.should be_false

    #copied_tile.image_processing.should be_false
    #copied_tile.thumbnail_processing.should be_false
    copied_tile.image_updated_at.should be_present
    copied_tile.thumbnail_updated_at.should be_present
    copied_tile.image_file_name.should == original_tile.image_file_name
    copied_tile.thumbnail_file_name.should == original_tile.thumbnail_file_name
  end
  #
  # => Functions for registration
  #
  NEW_CREATOR_NAME = "Johnny Cochran"
  NEW_CREATOR_EMAIL = "mustacquit@cochranlaw.com"
  NEW_CREATOR_PASSWORD = "ojtotallydidit"
  NEW_BOARD_NAME = "Law Offices Of J. Cochran"

  def fill_in_valid_form_entries
    within(create_account_form_selector) do 
      fill_in 'user[name]', with: NEW_CREATOR_NAME
      fill_in 'user[email]', with: NEW_CREATOR_EMAIL
      fill_in 'user[password]', with: NEW_CREATOR_PASSWORD
      fill_in 'board[name]', with: NEW_BOARD_NAME
    end
  end

  def submit_create_form
    element_selector = page.evaluate_script("window.pathForActionAfterRegistration")
    begin 
      click_button "Create Free Account"
    # actionElement[0].click(); - this code should make last 
    # action that guest user had made before registration.
    # this doesn't work in tests but works in code.
    # so i have to do this action in tests manually
    rescue Capybara::Poltergeist::JavascriptError
      page.find(element_selector).click
    end
  end

  def create_account_form_selector
    "form#create_account_form"
  end

  def register_if_guest
    if @user.nil? || !(@user.is_client_admin || @user.is_site_admin)
      page.should have_selector('#sign_up_modal', visible: true)
      fill_in_valid_form_entries
      submit_create_form
      @user = User.order("created_at DESC").first
      @user.name.should == NEW_CREATOR_NAME
    end
  end

  def upvote_tutorial_content
    "Like a tile? Vote it up to give the creator positive feedback."
  end

  def share_link_tutorial_content
    "Want to share a tile? Email it using the email icon. Or, share to your social networks using the LinkedIn icon or copying the link."
  end

  def click_next_intro_link
    page.find('.introjs-nextbutton').click
  end

  let (:creator) {FactoryGirl.create(:client_admin, name: "Charlotte McTilecreator")}
  let (:actor) {FactoryGirl.create(:client_admin, name: "Joe Copier")}
  let (:last_actor) {FactoryGirl.create(:client_admin, name: "John Lastactor")}
  let (:second_actor) {FactoryGirl.create(:client_admin, name: "Suzanne von Secondactor")}

  shared_examples_for 'copies/likes tile' do
    scenario "by clicking the proper link", js: true do
      close_intro
      click_copy_button
   
      crank_dj_clear
      expect_tile_copied(@original_tile, @user)
    end

    context "when the tile has no creator", js: true do
      before do
        @original_tile.update_attributes(creator: nil)
        close_intro
      end

      it "should work", js: true do
        click_copy_button
     
        crank_dj_clear
        expect_tile_copied(@original_tile, @user)
      end
    end

    scenario "should show a helpful message in a modal after copying", js: true do
      close_intro
      click_copy_button
      page.find('#tile_copied_lightbox', visible: true)

      expect_content post_copy_copy
    end

    scenario "works if no creator is set", js: true do
      close_intro
      @original_tile.update_attributes(creator: nil)
      click_copy_button
      page.find('#tile_copied_lightbox', visible: true)

      expect_content post_copy_copy
    end

    scenario "should ping", js: true do
      close_intro
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
      close_intro
      click_copy_button
    
      @original_tile.user_tile_copies.reload.first.user_id.should eq @user.id
    end
  
    scenario "should not show the link for a non-copyable tile", js: true do
      close_intro
      tile = FactoryGirl.create(:multiple_choice_tile, :public)
      visit explore_tile_preview_path(tile, as: @user)
      page.should have_content("View Only")
    end

    scenario "has credit for the original creator if present", js: true do
      close_intro
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

  shared_examples_for 'gets registration form' do |name, selector|
    scenario "when clicks #{name}", js: true do
      close_intro
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
      close_intro
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
      close_intro
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
    it_should_behave_like "gets registration form", "like button", ".not_like_button"
    it_should_behave_like "gets registration form", "copy button", "a .copy_button"
    it_should_behave_like "gets registration form", "random link", "#random-tile-link"
    it_should_behave_like "gets registration form", "back link", "#back-link"
    it_should_behave_like "gets registration form", "tag link", ".tag a"
    it_should_behave_like "gets registration form", "right arrow", "#next"
    it_should_behave_like "gets registration form", "left arrow", "#prev"
    it_should_behave_like "gets registration form", "logo", "#logo"

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
    it_should_behave_like "gets registration form", "like button", ".not_like_button"
    it_should_behave_like "gets registration form", "copy button", "a .copy_button"
    it_should_behave_like "gets registration form", "random link", "#random-tile-link"
    it_should_behave_like "gets registration form", "back link", "#back-link"
    it_should_behave_like "gets registration form", "tag link", ".tag a"
    it_should_behave_like "gets registration form", "right arrow", "#next"
    it_should_behave_like "gets registration form", "left arrow", "#prev"
    it_should_behave_like "gets registration form", "logo", "#logo"
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
    it_should_behave_like "gets registration form", "like button", ".not_like_button"
    it_should_behave_like "gets registration form", "copy button", "a .copy_button"
    it_should_behave_like "gets registration form", "random link", "#random-tile-link"
    it_should_behave_like "gets registration form", "back link", "#back-link"
    it_should_behave_like "gets registration form", "tag link", ".tag a"
    it_should_behave_like "gets registration form", "right arrow", "#next"
    it_should_behave_like "gets registration form", "left arrow", "#prev"
    it_should_behave_like "gets registration form", "logo", "#logo"
    it_should_behave_like "has intro modals"
  end
end
