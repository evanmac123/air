require 'acceptance/acceptance_helper'

feature "Client admin copies/likes tile from the explore-preview page" do
  def expect_copied_lightbox
    page.should have_content("You've added this tile to the inactive section of your board.")
  end

  def click_copy_button
    page.find('#copy_tile_button').click
    expect_copied_lightbox
  end

  def click_copy_link
    page.find('#copy_tile_link').click
    show_me_the_page
    expect_copied_lightbox
  end
 
  def click_like
    first('.not_like_button').click
  end

  def click_unlike_link
    page.first('.tile_liked a').click
  end

  def newest_tile
    Tile.order("created_at DESC").first
  end

  def expect_tile_copied(original_tile)
    copied_tile = newest_tile

    Tile.count.should == 2
    %w(correct_answer_index headline image_content_type image_file_size image_meta link_address multiple_choice_answers points question supporting_content thumbnail_content_type thumbnail_file_size thumbnail_meta type).each do |expected_same_field|
      copied_tile[expected_same_field].should == original_tile[expected_same_field]
    end

    copied_tile.status.should == Tile::DRAFT
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
      expect_tile_copied(@original_tile)
    end

    context "when the tile has no creator", js: true do
      before do
        @original_tile.update_attributes(creator: nil)
      end

      it "should work", js: true do
        click_copy_button
     
        crank_dj_clear
        expect_tile_copied(@original_tile)
      end
    end

    scenario "should show a helpful message in a modal after copying", js: true do
      click_copy_button
      page.find('#tile_copied_lightbox', visible: true)

      expect_content %(You've added this tile to the inactive section of your board. Next, you can edit this tile, go back to "Explore" or go to manage your board.)
    end

    scenario "works if no creator is set", js: true do
      @original_tile.update_attributes(creator: nil)
      click_copy_button
      page.find('#tile_copied_lightbox', visible: true)

      expect_content %(You've added this tile to the inactive section of your board. Next, you can edit this tile, go back to "Explore" or go to manage your board.)
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
      page.should have_content("Tile is view only")
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

    context "Proper copy on liking/copying" do
      [
        {action: :click_copy_button, past_tense: "copied", present_tense: 'copy'},
        {action: :click_like, past_tense: "liked",  present_tense: 'like'},
      ].each do |details|
        before do
          pending "A NUMBER OF THESE ARE KNOWN TO BE BROKEN, PENDING TEMPORARILY. IT'S MOSTLY JUST COMMAS."
        end

        scenario "visiting the page first time should show be the first person to #{details[:present_tense]} this tile", js: true do
          page.should have_content("Be the first person to #{details[:present_tense]} this tile")
        end
      
        scenario "hitting refresh should show #{details[:past_tense]} by you", js: true do
          send details[:action]
          visit explore_tile_preview_path(@original_tile)
          page.should have_content("#{details[:past_tense].capitalize} by you")
        end

        scenario "If someone else has #{details[:past_tense]} the tile page should show #{details[:past_tense]} by username", js: true do
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: actor)
          page.should have_content("#{details[:past_tense].capitalize} by #{admin.name}")
        end

        scenario "If someone else and you have #{details[:past_tense]} the tile page should show #{details[:past_tense]} by you and username", js: true do
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: actor)
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: actor)
          page.should have_content("#{details[:past_tense].capitalize} by you and #{admin.name}")
        end

        scenario "If only two people have #{details[:past_tense]} tile and you havent page should show #{details[:past_tense]} by last actor username and prior actor username", js: true do
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: last_actor)
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: actor)
          page.should have_content("#{details[:past_tense].capitalize} by #{last_actor.name} and #{admin.name}")
        end

        scenario "If #{details[:past_tense]} by more then two people and you havent page should show #{details[:past_tense]} by last #{details[:past_tense]} username, prior actor username and 1 other", js: true do
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: last_actor)
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: second_actor)
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: actor)
          page.should have_content("#{details[:past_tense].capitalize} by #{second_actor.name}, #{last_actor.name} and 1 other")
        end

        scenario "If #{details[:past_tense]} by more then two people and you have, page should show #{details[:past_tense]} by you, prior actor username and 2 others", js: true do
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: last_actor)
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: second_actor)
          send details[:action]

          visit explore_tile_preview_path(@original_tile, as: actor)
          send details[:action]

          page.should have_content("#{details[:past_tense].capitalize} by you, #{second_actor.name}, and 2 others")
        end
      end
    end
  end

  scenario "unliking a tile that was liked sometime in the past updates the page properly", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)
    client_admin = a_client_admin
    UserTileLike.create!(tile: tile, user: client_admin) # we liked this at some point in the past

    visit explore_path(as: client_admin)
    page.should have_content("1 Like")
    page.should have_no_content("0 Like")

    click_unlike_link
    page.should have_content("0 Like")
    page.should have_no_content("1 Like")
  end
end
