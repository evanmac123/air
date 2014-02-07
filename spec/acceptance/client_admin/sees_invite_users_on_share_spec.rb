require 'acceptance/acceptance_helper'

feature "Invite Users Modal" do
  def invite_users_modal_selector
    '#invite_users_modal'
  end
  
  def invite_users_modal_content
    'Now its time to share!'
  end
  
  def expect_hidden_invite_users_modal
    page.all(invite_users_modal_selector, visible: true).should be_empty
  end
    
  let (:client_admin) { FactoryGirl.create :client_admin}
  let (:client_admin2) { FactoryGirl.create :client_admin, show_invite_users_modal: false}
  context "when there's at least one active tile in the demo", js: true do
    before do
      FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: client_admin.demo)
      visit client_admin_share_path(as: client_admin)
    end

    scenario 'sees invite users modal and accompanying heading content and public link', js: true do
      within(invite_users_modal_selector) do
        expect_content invite_users_modal_content 
#        page.should have_content public_board_url(client_admin.demo.public_slug)
      end
    end

    scenario "makes modal go away by clicking a link and doesn't reappear when share page is revisited", js: true do
      within(invite_users_modal_selector) do
        click_link "Dismiss"
        expect_hidden_invite_users_modal
      end

      visit client_admin_share_path(as: client_admin)
      expect_hidden_invite_users_modal
    end
    context "inviting users", js: true do
      before do
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: client_admin2.demo)
        visit client_admin_share_path(as: client_admin2)
        #page.find('a#show_invite_users_modal').click      
        click_link 'invite users'
      end
#      scenario "show_user_invites_modal on click", js: true do 
#        page.all(invite_users_modal_selector, visible: true).should_not be_empty
#        within(invite_users_modal_selector) do
#          expect_content invite_users_modal_content 
#          page.all('input', text: public_board_url(client_admin2.demo.public_slug)).should_not be_empty
#        end
#      end
      scenario "Add another link adds two more fields", js: true do
        within(invite_users_modal_selector) do
          page.should have_css('input', count: 11)
          click_link "Add another"
          page.should have_css('input', count: 13)
        end
      end
      scenario "Form with empty values is not submitted" do
        within(invite_users_modal_selector) do
          click_link "Add and Send Invite"
          page.should have_css('#invite_users_modal_errors.error')
        end
      end

      scenario "Form with invalid email is not submitted" do
        within(invite_users_modal_selector) do        
          page.all('input#users_invite_users__name').first.set('Hisham Malik')
          page.all('input#users_invite_users__email').first.set('hishamexample.com')

          click_link "Add and Send Invite"
          page.should have_css('input.error')
        end
      end

      scenario "on successful submit, closes the invite_users_modal" do 
        within(invite_users_modal_selector) do        
          page.all('input#users_invite_users__name').first.set('Hisham Malik')
          page.all('input#users_invite_users__email').first.set('hisham@example.com')

          click_link "Add and Send Invite"
          page.should_not have_css('input.error')

          expect_hidden_invite_users_modal
        end
      end
      context "on sucessful_submit", js: true do
        before do
#          visit client_admin_share_path(as: client_admin2)
#          click_link "invite users"      
          
          within(invite_users_modal_selector) do        
            page.all('input#users_invite_users__name').first.set('Hisham Malik')
            page.all('input#users_invite_users__email').first.set('hisham@example.com')
            page.find('textarea').set('Custom User Invite Message')
            click_link "Add and Send Invite"
          end        
        end
        scenario "sends email invite to user via Airbo" do
          crank_dj_clear
          open_email('hisham@example.com')
          current_email.from.should contain('via Airbo')
          current_email have_body_text(/Custom\sUser\sInvite\sMessage/)
        end
      end
    end
  end
  context "when there is no active tile" do
    before do
      client_admin_no_tile = FactoryGirl.create :client_admin
      FactoryGirl.create(:tile, status: Tile::ARCHIVE, demo: client_admin_no_tile.demo)
      visit client_admin_share_path(as: client_admin_no_tile)
    end
    scenario "user invites page should not show when there is no active tile" do
      page.all(invite_users_modal_selector, visible: true).should be_empty
    end        
  end
end
