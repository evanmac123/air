require 'acceptance/acceptance_helper'
feature "Create Tile Modal" do
  def create_tile_modal_content
    'You need to add tiles before you can share your board.'
  end
  
  def create_tile_modal_selector
    '#create_tile_modal'
  end

  def expect_no_create_tile_modal
    page.all(create_tile_modal_selector).should be_empty
  end

  let (:demo)         { FactoryGirl.create :demo }
  let (:client_admin) { FactoryGirl.create :client_admin, demo: demo }
  context "if there are no active tiles", js: true do
    before do
      FactoryGirl.create(:tile, status: Tile::ARCHIVE, demo: client_admin.demo)
      client_admin.demo.tiles.active.should be_empty
      visit client_admin_share_path(as: client_admin)
    end
    scenario 'sees create tiles modal and accompanying heading content and public link', js: true do
      within(create_tile_modal_selector) do
        expect_content create_tile_modal_content 
        page.all('input', text: public_board_url(demo.public_slug))
      end
    end
    
    scenario "makes modal go away by clicking a link", js: true do
      within(create_tile_modal_selector) do
        click_link "Dismiss"
        expect_no_create_tile_modal
      end
    end
    scenario "clicking create tile takes user to new tiles page" do
      within(create_tile_modal_selector) do
        page.find('a#create_tile_button').click
        current_path.should == new_client_admin_tile_path
      end
    end
  end  
end