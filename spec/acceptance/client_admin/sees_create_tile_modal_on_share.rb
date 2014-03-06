require 'acceptance/acceptance_helper'
feature "Share Tile" do
  def invite_users_modal_selector
    '#invite_users_modal'
  end
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
#        #TODO page should redirect to invite user page after 5 seconds
#        #TODO page should take user to invite user page when user clicks next
#        #TODO when user fills in an email that is already in the system, then error message displays
#        #TODO when user fills in an email that is invalid, then the field show error
#         same as above #TODO when user clicks next with an invalid email and name, they see an error to fix
#        #TODO when user fill in a valid email not in the system, then the field shows checkmark
#        #TODO when user clicks next with a valid email and name, they see the custom message page
#        #TODO when user clicks next without any email and name provided, they see an error to provide email and name
#        #TODO on invite user message page, they see the iframe with email preview
         #TODO on invite user message, when user types in a message, that message gets update in the iframe
#        #TODO on invite user message, when user clicks Send, they are taken to an success page
#        #TODO invite user success page has ......
#        #TODO on invite user message success, and email gets sent with subject...., and message ....
#        #TODO on invite user message success, user sees the first activated tile.
        
      end
    end
    context "admin creates multiple tiles", js: true do
      before do
        3.times {FactoryGirl.create(:tile, status: Tile::ARCHIVE, demo: client_admin.demo)}
        visit client_admin_share_path(as: client_admin)
      end
      scenario "page should take user to invite user page when user clicks next after activating", js: true do
        page.find("#activate_all_tiles").click
        page.should have_content("You successfully activated your tiles. Next, share them with people.")
        page.find("#reveal_next_button").click
        page.all('#invite_users_modal', visible: true).should_not be_empty
      end
      scenario "page should redirect to invite user page after 5 seconds", js: true do
        page.find("#activate_all_tiles").click
        page.should have_content("You successfully activated your tiles. Next, share them with people.")
        sleep(5)
        page.all('#invite_users_modal', visible: true).should_not be_empty
      end
    end
  end
end