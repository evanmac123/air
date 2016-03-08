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
      pending "Fix this test"
      UserTileCopy.count.should eq 0
      click_copy
      click_close
      click_copy
      UserTileCopy.count.should eq 2
    end

    scenario 'clicking copy updates copy count on page', js: true do
      within(first '.like_copy_tile') do
        page.should have_content('Copy')
        click_link 'Copy'
      end
      click_close

      within(first '.like_copy_tile') do
        page.should have_content('Copied')
      end
    end

    scenario 'clicking copy on never-before-copied tile changes the class of the copy control wrapper so that styles will change', js: true do
      within(page.first('.explore_tile')) do 
        page.should have_selector('.not_copied')
        page.should have_no_selector('.copied')
        page.should have_content('Copy')
      end

      click_copy
      click_close

      within(page.first('.explore_tile')) do 
        page.should have_selector('.copied')
        page.should have_no_selector('.not_copied')
        page.should have_content('Copied')
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
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("1")
    end

    scenario 'Clicking on like link should change to liked and appear in blue', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("Voted Up")
    end

    scenario 'Clicking twice on Vote Up link should change to Voted Up and appear in blue', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
      UserTileLike.count.should eq 0
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("Voted Up")
      UserTileLike.count.should eq 1
      click_liked
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
      UserTileLike.count.should eq 0
    end

    scenario 'Clicking twice on Vote Up link should decrese the count', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
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

    scenario 'Clicks on VoteUp for a tile should increase the UserTileLike', js:true do
      UserTileLike.count.should eq 0
      click_like
      UserTileLike.count.should eq 1
      view_only_check
    end

    scenario 'Clicks on VoteUp for a tile in window count should increase', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("1")
      view_only_check
    end

    scenario 'Clicking on Vote Up link should change to Voted Up and appear in blue', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("Voted Up")
      view_only_check
    end

    scenario 'Clicking twice on Vote Up link should change to Voted Up and appear in blue', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
      UserTileLike.count.should eq 0
      click_like
      first('.like_copy_tile').find('.tile_liked').should have_content("Voted Up")
      UserTileLike.count.should eq 1
      click_liked
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
      UserTileLike.count.should eq 0
      view_only_check
    end

    scenario 'Clicking twice on Vote Up link should decrese the count', js:true do
      first('.like_copy_tile').find('.tile_not_liked').should have_content('Vote Up')
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
      current_email.should have_content "#{client_admin_copier.name} voted up your tile"
    end
  end

  def click_copy
    first('.not_copied').find('.copy_tile_link').click
    within '.tile_copied_lightbox' do 
      expect(page).to have_content(post_copy_copy)
    end
  end


  def click_close
    within '.tile_copied_lightbox' do 
      click_button "OK"
    end
  end

  def click_like
    first('.tile_not_liked').find('a').click
  end

  def click_liked
    first('.tile_liked').find('a').click
  end

  def view_only_check
    first('.like_copy_tile').find('.viewonly_message').should have_content('View Only')
  end

end



