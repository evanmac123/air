require 'acceptance/acceptance_helper'

feature "Client admin copies or likes tile" do
  let (:client_admin_maker) {a_client_admin}
  let (:client_admin_copier) {a_client_admin}
  before do
    @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, demo: client_admin_maker.demo)

    crank_dj_clear # to resize the images
    @original_tile.reload

  end

  
  context 'User on explore tiles page', js: true do
    before do
      FactoryGirl.create_list(:multiple_choice_tile, 8, :copyable, demo: client_admin_maker.demo)      
      crank_dj_clear # to resize the images
      visit explore_path(as: client_admin_maker)
    end
    
    def click_copy
      first('.not_copied').find('#copy_tile_link').click
      find('.reveal-modal').should have_content("You've added this tile to the inactive section of your board.")
    end
    
    scenario 'Clicking on copy for a tile increase UserTileCopy count', js: true do
      UserTileCopy.count.should eq 0
      click_copy        
      UserTileCopy.count.should eq 1
    end
    scenario 'Clicks on copy for a tile twice increases count by twice', js: true do
      UserTileCopy.count.should eq 0
      click_copy
      click_copy
      UserTileCopy.count.should eq 2
    end
    
    scenario 'Clicks on like for a tile should increase the UserTileLike', js:true do
      UserTileLike.count.should eq 0
      click_like       
      UserTileLike.count.should eq 1
      it 'after refreshing explore page the link with liked should appear', js: true do
        pending
      end
      scenario 'Clicking on liked should decrease teh UserTileLike', js:true do
        it 'should decrement the UserTileLike', js:true do
          pending
        end
        it 'should decrement the UserTileLike', js:true do
          pending
        end
      end
    end
  end
end
