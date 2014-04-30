require 'acceptance/acceptance_helper'

feature "Client admin likes tile from the explore-preview page" do
  def click_like
    page.find('.not_like_button').click
    page.should have_content("Liked")
  end
  
  def newest_tile
    Tile.order("created_at DESC").first
  end

  let (:admin) {a_client_admin}
  let (:creator) {a_client_admin}
  let (:liker) {a_client_admin}
  let (:last_liker) {a_client_admin}
  let (:second_liker) {a_client_admin}
  
  context 'Admin likes tile' do
    before do
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)

      crank_dj_clear # to resize the images
      @original_tile.reload

      visit explore_tile_preview_path(@original_tile, as: admin)
    end

    after do
      $TESTING_COPYING = false
    end
    scenario "by clicking the proper link", js: true do
      count = @original_tile.user_tile_likes.count
      click_like
      @original_tile.user_tile_likes.count.should eq count+1
      crank_dj_clear
    end


    scenario "should ping", js: true do
      crank_dj_clear
      FakeMixpanelTracker.clear_tracked_events

      click_like
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Explore page - Large Tile View', 
        {tile_id: @original_tile.id, action: 'Clicked Like'})
    end

    scenario "should record user who liked", js: true do
      click_copy
      @original_tile.user_tile_likes.reload.first.user_id.should eq admin.id
    end
  
    scenario 'visiting the page first time should show be the first person to like this tile', js: true do
      page.should have_content("Be the first person to like this tile")
    end
  
    scenario 'hitting refresh should show copied by you', js: true do
      click_copy
      visit explore_tile_preview_path(@original_tile, as: admin)
      page.should have_content("Copied by you")
    end
    scenario 'If someone else has copied the tile page should show copied by username', js: true do
      click_copy
      visit explore_tile_preview_path(@original_tile, as: copier)
      page.should have_content("Copied by #{copier.name}")
    end
    scenario 'If someone else and you have copied the tile page should show copied by you and username', js: true do
      click_copy
      visit explore_tile_preview_path(@original_tile, as: copier)
      page.should have_content("Copied by #{admin.name}")
      click_copy
      visit explore_tile_preview_path(@original_tile, as: copier)
      page.should have_content("Copied by you and#{admin.name}")
    end
    scenario 'If only two people have copied tile and you havent page should show copied by last copier username and prior copier username', js: true do
      click_copy
      visit explore_tile_preview_path(@original_tile, as: last_copier)
      page.should have_content("Copied by #{admin.name}")
      click_copy
      visit explore_tile_preview_path(@original_tile, as: last_copier)
      page.should have_content("Copied by you and#{last_copier.name}")
      visit explore_tile_preview_path(@original_tile, as: copier)
      page.should have_content("Copied by #{last_copier.name} and#{admin.name}")
    end
    scenario 'If copied by more then two people and you havent page should show copied by last copied username, prior copier username and 1 other', js: true do
      click_copy
      visit explore_tile_preview_path(@original_tile, as: last_copier)
      page.should have_content("Copied by #{admin.name}")
      click_copy
      visit explore_tile_preview_path(@original_tile, as: last_copier)
      page.should have_content("Copied by you and#{last_copier.name}")
      visit explore_tile_preview_path(@original_tile, as: last_copier)
      click_copy
      page.should have_content("Copied by #{last_copier.name} and#{admin.name}")
      visit explore_tile_preview_path(@original_tile, as: copier)
      page.should have_content("Copied by #{last_copier.name}, #{copier.name} and 1 other")
    end
    scenario 'If copied by more then two people and you have, page should show copied by you, prior copier username and 2 others', js: true do
      click_copy
      visit explore_tile_preview_path(@original_tile, as: last_copier)
      page.should have_content("Copied by #{admin.name}")
      click_copy
      visit explore_tile_preview_path(@original_tile, as: last_copier)
      page.should have_content("Copied by you and#{last_copier.name}")
      click_copy
      visit explore_tile_preview_path(@original_tile, as: last_copier)
      page.should have_content("Copied by #{last_copier.name} and#{admin.name}")
      visit explore_tile_preview_path(@original_tile, as: copier)
      page.should have_content("Copied by #{last_copier.name}, #{copier.name} and 1 other")
      click_copy
      page.should have_content("Copied by you, #{last_copier.name} and 2 others")
    end
  end
end