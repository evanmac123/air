require 'acceptance/acceptance_helper'

feature "Invite Users Modal" do
  def invite_users_modal_selector
    '#invite_users_modal'
  end
  
  def invite_users_modal_content
    'Invite people to your board'
  end
  
  def expect_hidden_invite_users_modal
    page.all(invite_users_modal_selector, visible: true).should be_empty
  end
    
  let (:client_admin) { FactoryGirl.create :client_admin}
  let (:client_admin2) { FactoryGirl.create :client_admin}
  let (:user) {FactoryGirl.create(:user)}
  context "when there's at least one active tile in the demo", js: true do
    before do
      FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: client_admin.demo)
      visit client_admin_share_path(as: client_admin)
    end
    scenario "sends mixpanel ping" do
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      properties = {page_name: 'Share'}
      FakeMixpanelTracker.should have_event_matching('viewed page', properties)
    end
    scenario 'sees invite users modal and accompanying username and email fields', js: true do
      expect_content invite_users_modal_content 
      page.all(invite_users_modal_selector, visible: true).should_not be_empty
    end
    scenario "'Add More' link adds two more fields" do
      within(invite_users_modal_selector) do
        page.should have_css('input', count: 17)
        page.find('#add_another_user_invite').click
        page.should have_css('input', count: 19)
      end
    end
    scenario "clicking skip will display share url page" do
      page.find("#skip_invite_users").click
      page.all('#success_share_url', visible: true).should_not be_empty
      
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      properties = {action: 'Clicked Skip link'}
      FakeMixpanelTracker.should have_event_matching('Share - Add First Users', properties)          
    end
    scenario "pings on clicking elements after clicking skip button" do
      page.find("#skip_invite_users").click
      
      within('#share_link', visible: true) do
        page.find('.email').click            
        FakeMixpanelTracker.clear_tracked_events
        crank_dj_clear
        properties = {action: 'Clicked Email Share Icon'}
        FakeMixpanelTracker.should have_event_matching('Share - Using Link Only', properties)            
      end
      within('#share_link', visible: true) do
        page.find('.twitter').click
        FakeMixpanelTracker.clear_tracked_events
        crank_dj_clear
        properties = {action: 'Clicked Twitter Share Icon'}
        FakeMixpanelTracker.should have_event_matching('Share - Using Link Only', properties)            
      end
      within('#message_div', visible: true) do
        page.find('.history_back').click
        FakeMixpanelTracker.clear_tracked_events
        crank_dj_clear
        properties = {action: 'Clicked Add Users'}
        FakeMixpanelTracker.should have_event_matching('Share - Using Link Only', properties)                
      end
    end
    scenario "form with invalid email is not submitted" do
      within(invite_users_modal_selector) do        
        find_field('user_0_name').set 'Hisham Malik'
        find_field('user_0_email').set 'hishamexample.com'
        page.find('#submit_invite_users').click
        page.should have_css('input.error', visible: true)
      end
    end
    scenario "ping on clicking contact us" do
      click_link "Contact us"
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      properties = {action: 'Clicked To upload a list, contact us'}
      FakeMixpanelTracker.should have_event_matching('Share - Add First Users', properties)
    end
    scenario "form with invalid email is not submitted" do
      within(invite_users_modal_selector) do        
        find_field('user_0_name').set 'Hisham Malik'
        find_field('user_0_email').set 'hishamexample.com'
        page.find('#submit_invite_users').click
        page.should have_css('input.error', visible: true)
      end
    end    
    scenario "form with no values shows error message" do
      page.find('#submit_invite_users').click
      page.should have_content("Please specify at least one user")
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
        scenario "pings on clicking add more users button", js: true do
          click_link "Add More Users"
          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          properties = {action: 'Clicked Add More Users'}
          FakeMixpanelTracker.should have_event_matching('Share - Send Invitation', properties)          
        end
        scenario "pings on clicking preview invitation button", js: true do
          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          properties = {action: 'Clicked Preview Invitation button'}
          FakeMixpanelTracker.should have_event_matching('Share - Add First Users', properties)          
        end        
        scenario "pings on valid entries", js: true do
          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          properties = {action: 'Added Valid User'}
          FakeMixpanelTracker.should have_event_matching('Share - Add First Users', properties)          
        end        
        scenario "pings number of valid users", js: true do
          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          properties = {action: 'Number of valid users added', num_valid_users: "1"}
          FakeMixpanelTracker.should have_event_matching('Share - Add First Users', properties)          
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
          
          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          properties = {action: 'Clicked Send'}
          FakeMixpanelTracker.should have_event_matching('Share - Send Invitation', properties)
          
          page.should have_content("Invitation Sent!")
          page.should have_css('#success_section', visible: true)
          page.should have_content("You can also share your board using this link")
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
          page.should have_content("Invitation Sent!")
          page.should have_css('#success_section', visible: true)
          page.should have_content("You can also share your board using this link")
          page.should have_css('.share_url_link', visible: true)          
        end
        scenario "pings on clicking mail icon" do
          page.find("#invite_users_send_button").click
          within('#share_link', visible: true) do
            page.find('.email').click            
            FakeMixpanelTracker.clear_tracked_events
            crank_dj_clear
            properties = {action: 'Clicked Email Share Icon'}
            FakeMixpanelTracker.should have_event_matching('Share - Invitation Sent Confirmation', properties)            
          end
        end        
        scenario "pings on clicking twitter icon" do
          page.find("#invite_users_send_button").click
          within('#share_link', visible: true) do
            page.find('.twitter').click
            FakeMixpanelTracker.clear_tracked_events
            crank_dj_clear
            properties = {action: 'Clicked Twitter Share Icon'}
            FakeMixpanelTracker.should have_event_matching('Share - Invitation Sent Confirmation', properties)            
          end
        end        
      end
    end
  end
end
