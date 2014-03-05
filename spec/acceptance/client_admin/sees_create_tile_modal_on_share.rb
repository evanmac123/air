require 'acceptance/acceptance_helper'
feature "Share Tile" do
  def create_tile_modal_content
    'You need to create a tile before you can share'
  end
  
  def create_tile_modal_selector
    '#create_tile_modal'
  end

  def expect_no_create_tile_modal
    page.all(create_tile_modal_selector).should be_empty
  end
  let (:demo)         { FactoryGirl.create :demo }
  let (:client_admin) { FactoryGirl.create :client_admin, demo: demo }
  context "if there are no created tiles", js: true do
    context "admin visits share page", js: true do
      before do
        visit client_admin_share_path(as: client_admin)
        client_admin.demo.tiles.should be_empty
      end
      scenario 'sees instructions to create tile before sharing', js: true do
        expect_content create_tile_modal_content
        page.should have_link('Explore', client_admin_explore_path)
        page.should have_link('Create Tile', new_client_admin_tile_path)
        page.should have_content("You need to create a tile before you can share")
      end
      scenario "clicking 'create tile' takes user to new tiles page" do
        click_link("Create Tile")
        current_path.should == new_client_admin_tile_path
      end
    end
    context "admin creates a tile but doesnt activate it", js: true do
      before do
        FactoryGirl.create(:tile, status: Tile::ARCHIVE, demo: client_admin.demo)
        visit client_admin_share_path(as: client_admin)
      end
      scenario "sees instructions to activate tile before sharing", js: true do
        page.should have_content "You need to activate tiles before you can share"
      end
    end
    context "admin activates a tile", js: true do
      before do
        FactoryGirl.create(:tile, status: Tile::ARCHIVE, demo: client_admin.demo)
        visit client_admin_share_path(as: client_admin)
      end
      scenario "clicks 'activate tile'", js: true do
        page.execute_script("$('.activate_button').click();")
        page.should have_css("#success_activated_tiles")
      end
    end
    context "admin creates multiple tiles", js: true do
      before do
        3.times {FactoryGirl.create(:tile, status: Tile::ARCHIVE, demo: client_admin.demo)}
        visit client_admin_share_path(as: client_admin)
      end
      scenario "activates all of them", js: true do
        page.find("#activate_all_tiles").click
        page.should have_content("You successfully activated your tiles. Next, share them with people.")
        page.find("#reveal_next_button").click
        page.all('#invite_users_modal', visible: true).should_not be_empty
      end
    end
  end
end