require 'acceptance/acceptance_helper'

feature "Invite Users Modal" do
  def invite_users_modal_selector
    '#invite_users_modal'
  end
  
  def invite_users_modal_content
    'Who would you like to share your board with?'
  end
  
  def expect_hidden_invite_users_modal
    page.all(invite_users_modal_selector, visible: true).should be_empty
  end
    
  let (:client_admin) { FactoryGirl.create :client_admin}
  let (:client_admin2) { FactoryGirl.create :client_admin, show_invite_users_modal: false}
  let (:user) {FactoryGirl.create(:user)}
  context "when there's at least one active tile in the demo", js: true do
    before do
      FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: client_admin.demo)
      visit client_admin_share_path(as: client_admin)
    end
    scenario 'sees invite users modal and accompanying username and email fields', js: true do
      expect_content invite_users_modal_content 
      page.all(invite_users_modal_selector, visible: true).should_not be_empty
    end
    scenario "'More People' link adds two more fields" do
      within(invite_users_modal_selector) do
        page.should have_css('input', count: 17)
        click_link "+ More People"
        page.should have_css('input', count: 19)
      end
    end
    scenario "'Contact us' link opens help chat bubble" do
      #this functionality is not implemented yet. need to verify it
    end
    scenario "clicking skip will display share url page" do
      page.find("#skip_invite_users").click
      page.all('#success_share_url', visible: true).should_not be_empty
    end    
    scenario "form with invalid email is not submitted" do
      within(invite_users_modal_selector) do        
        find_field('user_0_name').set 'Hisham Malik'
        find_field('user_0_email').set 'hishamexample.com'
        page.find('#submit_invite_users').click
        page.should have_css('input.error', visible: true)
      end
    end
    context "inviting users", js: :webkit do
      before do
        $rollout.activate_user(:public_board, client_admin2.demo)
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: client_admin2.demo)
        visit client_admin_share_path(as: client_admin2)        
      end
      scenario "should give error on adding existing users", js: true do
        page.find_field('user_0_name').set "#{user.name}"
        page.find_field('user_0_email').set "#{user.email}"
        page.find('#submit_invite_users').click
        page.should have_css('input.error', visible: true)
      end
      scenario "on successful submit, hides the invite_users_modal" do 
        within(invite_users_modal_selector) do        
          page.find_field('user_0_name').set('Hisham Malik')
          page.find_field('user_0_name').value.should contain('Hisham Malik')
          find_field('user_0_email').set 'hisham@example.com'
          page.find('#submit_invite_users').click
          page.should_not have_css('input.error')
          expect_hidden_invite_users_modal
        end
      end
      context "on sucessful_submit", js: :webkit do
        before do
          visit client_admin_share_path(as: client_admin2)          
          find_field('user_0_name').set 'Hisham Malik'
          find_field('user_0_email').set 'hisham@example.com'
          page.find('#submit_invite_users').click
        end
        scenario "on valid username and email, page displays custom message page" do
          page.should have_css("#user_invite_message_custom", visible: true)
        end
        scenario "custom message page shows email preview" do
          page.should have_css(".iframe", visible: true)
          within(".iframe") do
            page.should have_css("#share_tiles_email_preview_blocker", visible: true)
          end
        end
        scenario "email preview shows updated custom message", js: true do
          page.find('#users_invite_message').set "this is a custom message "          
          within("#share_tiles_email_preview") do
            #TODO needs to find #custom_message in iframe and match the custom message
#            page.should have_content("this is a custom message")
          end
        end
        scenario "sends email invite to user via Airbo" do
          page.find("#invite_users_send_button").click
          crank_dj_clear
          open_email('hisham@example.com')
          current_email['from'].should contain('via Airbo')
        end
        scenario "after clicking send, page shows success message along with share url page" do
          before do
            3.times {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: client_admin.demo)}
          end
          page.find("#invite_users_send_button").click
          page.should have_content("Congratulations! You've sent your first tiles.")
          page.should have_css('#success_section', visible: true)
          page.should have_content("You can also share your board using a link")
          page.should have_css('.share_url', visible: true)
          within("#share_active_tile") do
            page.find(".active").should have_css('.tile_thumbnail', visible: true, count: 1)
          end
        end
      end
    end
  end
end