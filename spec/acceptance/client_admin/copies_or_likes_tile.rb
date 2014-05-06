require 'acceptance/acceptance_helper'

feature "Client admin copies or likes tile" do
  let (:client_admin_maker) {a_client_admin}
  let (:client_admin_copier) {a_client_admin}
  before do
    @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, 
      creator: client_admin_maker, demo: client_admin_maker.demo)
    crank_dj_clear # to resize the images
    @original_tile.reload
  end

      
  def click_copy
    first('.not_copied').find('.copy_tile_link').click
    find('.reveal-modal').should have_content("You've added this tile to the inactive section of your board.")   
  end
  def click_close
    page.find('#close_tile_copied_lightbox').click
  end
    
  def click_like
    first('.tile_not_liked').find('a').click
  end
    
  def click_liked
    first('.tile_liked').find('a').click
  end

  def view_only_check
    first('.like_copy_tile').find('.view_only').should have_content('View only')
  end

  context 'User on explore tiles page', js: true do
    before do
      FactoryGirl.create_list(:multiple_choice_tile, 8, :copyable, 
        creator: client_admin_maker,
        demo: client_admin_maker.demo)      
      crank_dj_clear # to resize the images
      visit explore_path(as: client_admin_copier)
    end
    
    scenario 'Clicking on copy for a tile increase UserTileCopy count', js: true do
      UserTileCopy.count.should eq 0
      click_copy        
      UserTileCopy.count.should eq 1
    end

    scenario 'Clicks on copy for a tile twice increases count by twice', js: true do
      UserTileCopy.count.should eq 0
      click_copy
      click_close
      click_copy
      UserTileCopy.count.should eq 2
    end

    scenario 'clicking copy updates copy count on page', js: true do
      within(first '.like_copy_tile') do
        page.should have_content('0 Copy')
        click_link 'Copy'
      end
      click_close

      within(first '.like_copy_tile') do
        page.should have_content('1 Copy')
      end
    end

    scenario 'Clicks on copy for a tile the refresing the page should have copied link instead of copy link', js: true do
      UserTileCopy.count.should eq 0
      click_copy
      click_close
      visit explore_path(as: client_admin_copier)
      first('.like_copy_tile .copied').should have_content('Copied')   
    end

    scenario 'Clicks on copy for a tile the refresing the page should have copy count increased by 1', js: true do
      UserTileCopy.count.should eq 0
      click_copy
      click_close
      visit explore_path(as: client_admin_copier)
      first('.like_copy_tile .copied').should have_content('1')  
    end
    
    scenario 'Clicks on like for a tile should increase the UserTileLike', js:true do
      UserTileLike.count.should eq 0
      click_like
      UserTileLike.count.should eq 1
    end

    scenario 'Clicks on like for a tile in window count should increase', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('0')
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("1")
    end

    scenario 'Clicking on like link should change to liked and appear in blue', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Like')
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("Liked")
    end

    scenario 'Clicking twice on like link should change to like and appear in blue', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Like')
      UserTileLike.count.should eq 0
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("Liked")
      UserTileLike.count.should eq 1
      click_liked
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Like')
      UserTileLike.count.should eq 0
    end

    scenario 'Clicking twice on like link should decrese the count', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Like')
      UserTileLike.count.should eq 0
      click_like
      UserTileLike.count.should eq 1
      click_liked
      UserTileLike.count.should eq 0
    end
  end
  
  context 'User on explore tiles page with uncopyable tiles', js: true do
    before do
      FactoryGirl.create_list(:multiple_choice_tile, 8, :public, demo: client_admin_maker.demo, creator: client_admin_maker)
      crank_dj_clear # to resize the images
      visit explore_path(as: client_admin_copier)
    end

    scenario 'Tile copy should should view only', js: true do
      view_only_check
    end

    scenario 'Clicks on like for a tile should increase the UserTileLike', js:true do
      UserTileLike.count.should eq 0
      click_like
      UserTileLike.count.should eq 1
      view_only_check
    end

    scenario 'Clicks on like for a tile in window count should increase', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('0')
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("1")
      view_only_check
    end

    scenario 'Clicking on like link should change to liked and appear in blue', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Like')
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("Liked")
      view_only_check
    end

    scenario 'Clicking twice on like link should change to like and appear in blue', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Like')
      UserTileLike.count.should eq 0
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("Liked")
      UserTileLike.count.should eq 1
      click_liked
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Like')
      UserTileLike.count.should eq 0
      view_only_check
    end

    scenario 'Clicking twice on like link should decrese the count', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Like')
      UserTileLike.count.should eq 0
      click_like
      UserTileLike.count.should eq 1
      click_liked
      UserTileLike.count.should eq 0
      view_only_check
    end

    scenario 'Clicking on like link should send an email', js:true do
      click_like
      
      Timecop.travel(15.minutes + 1.second)
      crank_dj_clear
      all_emails.should have(1).emails
      open_email(client_admin_maker.email)
      current_email.should have_content "#{client_admin_copier.name} liked your tile"
    end
  end
end
