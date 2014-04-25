require 'acceptance/acceptance_helper'

feature "Client admin copies or likes tile" do
  let (:client_admin_maker) {a_client_admin}
  let (:client_admin_copier) {a_client_admin}
  before do
    @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, demo: client_admin_maker.demo)

    crank_dj_clear # to resize the images
    @original_tile.reload

  end

  context 'User on explore tiles page' do
    before do
      FactoryGirl.create_list(:multiple_choice_tile, 8, :copyable, demo: client_admin_maker.demo)
      visit explore_path(as: client_admin_copier)      
      
    end
    
    scenario 'Clicks on like for a tile',js:true do
      it 'should be in grey color before user has liked the link',js:true do
        pending
      end
      it 'should increment the UserTileLike', js:true do
        pending
      end
      it 'after refreshing explore page the link with liked should appear', js:true do
        pending
      end
      scenario 'Clicking on liked after redirection', js:true do
        it 'should decrement the UserTileLike', js:true do
          pending
        end
        it 'should decrement the UserTileLike', js:true do
          pending
        end
      end
    end
  end
  
  context 'User on explore tiles page' do
    before do
      FactoryGirl.create_list(:multiple_choice_tile, 8, :copyable, demo: client_admin_maker.demo)      
      visit explore_tile_preview_path(Tile.first)
    end
    
    scenario 'Clicks on copy for a tile', js:true do
      it 'should increment the UserTileCopy' do
        pending
      end      
    end
    scenario 'Clicks on copy for a tile twice', js: true do
      it 'should mark the copy twice'
      it 'should show the count as two in the stats for tiles'
    end
    
    scenario 'Clicks on like for a tile', js:true do
      it 'should be in grey color before user has liked the link', js:true do
        pending
      end
      it 'should increment the UserTileLike', js:true do
        pending
      end
      it 'after refreshing explore page the link with liked should appear', js:true do
        pending
      end
      scenario 'Clicking on liked after redirection', js:true do
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
