require 'acceptance/acceptance_helper'

include EmailHelper

feature 'Client admin and the digest email for tiles' do

  let(:demo)  { FactoryGirl.create :demo, email: 'foobar@playhengage.com' }
  let(:admin) { FactoryGirl.create :client_admin, email: 'client-admin@hengage.com', demo: demo }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  # -------------------------------------------------

  def have_send_on_selector(select = nil)
    options = select.nil? ? {} : {selected: select}
    have_select 'digest_send_on', options
  end

  def have_send_to_selector(selected)
    have_select 'digest_send_to', {selected: selected}
  end

  def have_follow_up_selector(selected)
    have_select 'digest_follow_up', {selected: selected}
  end

  def change_send_on(day)
    select day, from: 'digest_send_on'
  end

  def change_send_to(send_to)
    select send_to, from: 'digest_send_to'
  end

  def change_follow_up(num_days)
    select num_days, from: 'digest_follow_up'
  end

  def set_send_on(day)
    demo.update_attributes tile_digest_email_send_on: day
  end

  def set_last_sent_on(day)
    demo.update_attributes tile_digest_email_sent_at: day_to_time(day)
  end

  def set_follow_up(num_days)
    demo.update_attributes follow_up_digest_email_days: num_days
  end

  def expect_digest_to(recipient)
    digest_email = find_email(recipient)
    digest_email.should_not be_nil

    digest_email.from.should have(1).address
    digest_email.from.first.should == demo.email
  end

  def create_follow_up_emails
    @follow_up_1 = FactoryGirl.create :follow_up_digest_email, demo: demo, tile_ids: [1, 2], send_on: Date.new(2013, 7, 1)
    @follow_up_2 = FactoryGirl.create :follow_up_digest_email, demo: demo, tile_ids: [1, 2], send_on: Date.new(2013, 7, 2)
    @follow_up_3 = FactoryGirl.create :follow_up_digest_email, demo: demo, tile_ids: [1, 2], send_on: Date.new(2013, 7, 3)
  end

# -------------------------------------------------

  context 'No tiles exist for digest email' do

    before(:each) do
      visit tile_manager_page
      select_tab 'Digest email'
    end

    scenario 'Tab text is correct when there are no new tiles for the digest email' do
      last_email_sent_text = 'since the last one was sent on Thursday, July 04, 2013'

      digest_tab.should contain 'No digest email is scheduled to be sent because no new tiles have been added'

      # We have yet to consummate the sending of our virgin digest email
      digest_tab.should_not contain last_email_sent_text

      set_last_sent_on '7/4/2013'
      refresh_tile_manager_page

      digest_tab.should contain last_email_sent_text
    end

    scenario 'Form components and text are not on the page when there are no new tiles for the digest email' do
      digest_tab.should_not have_send_on_selector
      digest_tab.should_not have_button 'Send now'

      digest_tab.should_not contain 'A digest email containing'

      set_last_sent_on '7/4/2013'
      refresh_tile_manager_page

      digest_tab.should_not contain 'Last digest email was sent on'
    end

    scenario 'No follow-up emails are scheduled to be sent' do
      digest_tab.should_not contain 'A follow-up digest email is scheduled to go out'
    end

    scenario 'Follow-up emails are scheduled to be sent', js: :webkit do  # Didn't work with poltergeist... wtf!
      create_follow_up_emails
      refresh_tile_manager_page

      digest_tab.should contain 'A follow-up digest email is scheduled to go out'
      digest_tab.should contain 'Monday, July 01, 2013'
      digest_tab.should contain 'Tuesday, July 02, 2013'
      digest_tab.should contain 'Wednesday, July 03, 2013'

      first(:link, "Cancel").click
      # Notice we have the 'Cancel' link-text here, because the just-date string appears in the cancellation message
      digest_tab.should_not contain 'Monday, July 01, 2013 Cancel'
      digest_tab.should contain 'Follow-up email for Monday, July 01, 2013 cancelled'

      # Ensure that the follow-up email record was actually deleted
      refresh_tile_manager_page
      digest_tab.should_not contain 'Monday, July 01, 2013'
      digest_tab.should contain 'Tuesday, July 02, 2013'
      digest_tab.should contain 'Wednesday, July 03, 2013'
    end
  end

  context 'Tiles exist for digest email' do
    scenario "The number of tiles is correct, as is the plurality of the word 'tile'" do
      create_tile
      visit tile_manager_page
      select_tab 'Digest email'

      digest_tab.should contain 'A digest email containing 1 tile is set to go out'

      create_tile
      refresh_tile_manager_page
      select_tab 'Digest email'

      digest_tab.should contain 'A digest email containing 2 tiles is set to go out'
    end

    scenario 'The appropriate form components are on the page and properly initialized', js: true do
      create_tile
      visit tile_manager_page
      select_tab 'Digest email'

      digest_tab.should have_send_on_selector('Never')
      digest_tab.should have_follow_up_selector('Never')

      set_send_on 'Tuesday'
      set_follow_up '2'

      refresh_tile_manager_page
      select_tab 'Digest email'

      digest_tab.should have_send_on_selector('Tuesday')
      digest_tab.should have_follow_up_selector('2')
    end

    scenario "The 'send-on' drop-down control updates the day and time, and displays a confirmation message", js: true do
      create_tile
      visit tile_manager_page
      select_tab 'Digest email'

      digest_tab.should have_send_on_selector('Never')
      digest_tab.should_not contain 'at noon,'

      change_send_on 'Tuesday'

      digest_tab.should have_send_on_selector('Tuesday')
      digest_tab.should contain 'Send-on day updated to Tuesday'
      digest_tab.should contain 'at noon,'

      change_send_on 'Friday'

      digest_tab.should have_send_on_selector('Friday')
      digest_tab.should contain 'Send-on day updated to Friday'
      digest_tab.should contain 'at noon,'

      refresh_tile_manager_page
      select_tab 'Digest email'

      digest_tab.should contain 'at noon,'

      change_send_on 'Never'
      digest_tab.should contain 'Send-on day updated to Never'
      digest_tab.should_not contain 'at noon,'
    end

    scenario 'The admin can choose whether to send to everyone or just claimed users', js: true do
      create_tile
      visit tile_manager_page
      select_tab 'Digest email'

      digest_tab.should have_send_to_selector('all users')
      demo.unclaimed_users_also_get_digest.should be_true

      change_send_to 'only joined users'
      digest_tab.should contain 'Only joined users will get digest emails'
      demo.reload.unclaimed_users_also_get_digest.should be_false

      change_send_to 'all users'
      digest_tab.should contain 'All users will get digest emails'
      demo.reload.unclaimed_users_also_get_digest.should be_true
    end

    scenario "The selector for whether unclaimed users get digests should agree with the demo's state", js: true do
      create_tile
      visit tile_manager_page
      select_tab 'Digest email'

      digest_tab.should have_send_to_selector('all users')

      change_send_to 'only joined users'
      visit tile_manager_page
      digest_tab.should have_send_to_selector('only joined users')

      change_send_to 'all users'
      visit tile_manager_page
      digest_tab.should have_send_to_selector('all users')
    end

    scenario "The 'follow-up' drop-down control updates the number-of-days and displays a confirmation message", js: true do
      create_tile
      visit tile_manager_page
      select_tab 'Digest email'

      digest_tab.should have_follow_up_selector('Never')

      change_follow_up '1'

      digest_tab.should have_follow_up_selector('1')
      digest_tab.should contain 'Follow-up digest email will be sent 1 day after the original'

      change_follow_up '10'

      digest_tab.should have_follow_up_selector('10')
      digest_tab.should contain 'Follow-up digest email will be sent 10 days after the original'
    end

    scenario 'No follow-up emails are scheduled to be sent' do
      visit tile_manager_page
      select_tab 'Digest email'

      digest_tab.should_not contain 'A follow-up digest email is scheduled to go out'
    end

    scenario 'Follow-up emails are scheduled to be sent', js: :webkit do  # Didn't work with poltergeist... wtf!
      # If you first 'create_follow_up_emails' and then 'visit tile_manager_page'... well, you can't because the follow-up creation bombs
      visit tile_manager_page
      select_tab 'Digest email'

      create_follow_up_emails
      refresh_tile_manager_page

      digest_tab.should contain 'A follow-up digest email is scheduled to go out'
      digest_tab.should contain 'Monday, July 01, 2013'
      digest_tab.should contain 'Tuesday, July 02, 2013'
      digest_tab.should contain 'Wednesday, July 03, 2013'

      first(:link, "Cancel").click
      # Notice we have the 'Cancel' link-text here, because the just-date string appears in the cancellation message
      digest_tab.should_not contain 'Monday, July 01, 2013 Cancel'
      digest_tab.should contain 'Follow-up email for Monday, July 01, 2013 cancelled'

      # Ensure that the follow-up email record was actually deleted
      refresh_tile_manager_page
      digest_tab.should_not contain 'Monday, July 01, 2013'
      digest_tab.should contain 'Tuesday, July 02, 2013'
      digest_tab.should contain 'Wednesday, July 03, 2013'
    end

    scenario 'The last-digest-email-sent-on date is correct', js: true do
      visit tile_manager_page
      select_tab 'Digest email'
      digest_tab.should_not contain 'Last digest email was sent'

      set_last_sent_on '7/4/2013'

      visit tile_manager_page
      select_tab 'Digest email'
      digest_tab.should contain 'since the last one was sent on Thursday, July 04, 2013'
    end

    context "Clicking the 'Send now' button" do
      before(:each) do
        set_last_sent_on '7/4/2013'
        2.times { |i| create_tile on_day: '7/5/2013', activated_on: '7/5/2013', status: Tile::ACTIVE, headline: "Headline #{i + 1}"}
      end

      scenario "A flash confirmation message is displayed,
                the last-digest-email-sent-on date is updated,
                and a no-tiles message appears in the Digest tab" do
        on_day '7/6/2013' do
          visit tile_manager_page
          select_tab 'Digest email'
          change_send_on 'Never'  # Just to make sure that 'Send Now' does just that even if set to 'Never'

          digest_tab.should     contain 'A digest email containing 2 tiles is set to go out'
          digest_tab.should_not contain 'No digest email is scheduled to be sent'
          digest_tab.should_not contain 'since the last one was sent on Saturday, July 06, 2013'

          digest_tab.should contain 'Headline 1'
          digest_tab.should contain 'Headline 2'

          digest_tab.should have_num_tiles(2)

          click_button 'Send now'
          crank_dj_clear

          page.should contain "Tiles digest email was sent"

          select_tab 'Digest email'
          digest_tab.should_not contain 'A digest email containing 2 tiles is set to go out'
          digest_tab.should     contain 'No digest email is scheduled to be sent'
          digest_tab.should     contain 'since the last one was sent on Saturday, July 06, 2013'

          digest_tab.should_not contain 'Headline 1'
          digest_tab.should_not contain 'Headline 2'

          digest_tab.should have_num_tiles(0)
        end
      end

      context 'emails are sent to the appropriate people' do
        before do
          FactoryGirl.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
          FactoryGirl.create :user, demo: demo, name: 'Irma Thoman',   email: 'irma@thomas.com'

          FactoryGirl.create :claimed_user, demo: demo, name: 'W.C. Clark', email: 'wc@clark.com'
          FactoryGirl.create :claimed_user, demo: demo, name: 'Taj Mahal',  email: 'taj@mahal.com'

          FactoryGirl.create :site_admin, demo: demo, name: 'Eric Claption',  email: 'site-admin@hengage.com'

          FactoryGirl.create :user,         demo: FactoryGirl.create(:demo)  # Make sure these users from other
          FactoryGirl.create :claimed_user, demo: FactoryGirl.create(:demo)  # demos don't get an email

          visit tile_manager_page
          select_tab 'Digest email'
        end

        scenario "Demo where everybody, claimed and unclaimed, should get digests.
                  The tile links should sign in claimed *non-client-admin* users to the
                  Activities page, while whisking others to where they belong" do
          on_day '7/6/2013' do
            click_button 'Send now'
            crank_dj_clear

            all_emails.should have(6).emails  # The above 5 for this demo, and the 'client-admin' created at top of tests

            %w(client-admin@hengage.com site-admin@hengage.com john@campbell.com irma@thomas.com wc@clark.com taj@mahal.com).each do |address|
              expect_digest_to(address)

              open_email(address)

              name = User.find_by_email(address).first_name
              if %w(site-admin@hengage.com wc@clark.com taj@mahal.com).include?(address)  # Claimed, non-client-admin user?
                email_link = /tile_token/
                page_text_1 = "Welcome back, #{name}"
                page_text_2 = "Invite your friends"
              elsif address == 'client-admin@hengage.com' # client-admin?
                # client-admin was signed in at top of tests => needs to sign out in order to get sent to the Log-In page
                click_link "Sign Out"

                email_link = /acts/
                page_text_1 = "Log In"
                page_text_2 = "Remember me"
              else
                email_link = /invitations/
                page_text_1 = "Welcome, #{name}"
                page_text_2 = "Just set a password, and you're ready to go"
              end

              click_email_link_matching email_link

              page.should have_content page_text_1
              page.should have_content page_text_2
            end
          end
        end

        scenario 'Demo where only claimed users should get digests' do
          demo.update_attributes(unclaimed_users_also_get_digest: false)

          on_day '7/6/2013' do
            click_button 'Send now'
            crank_dj_clear

            all_emails.should have(4).emails  # 2 claimed users, the 'site-admin', and the 'client-admin' (created at top of tests)

            %w(client-admin@hengage.com wc@clark.com taj@mahal.com).each do |address|
              expect_digest_to(address)
            end
          end
        end
      end
    end
  end

  it 'Tiles appear in reverse-chronological order by activation-date and then creation-date' do
    tile_digest_email_sent_at = 2.months.ago
    demo.update_attributes tile_digest_email_sent_at: tile_digest_email_sent_at

    # Chronologically-speaking, creating tiles "up" from 0 to 10 and then checking "down" from 10 to 0
    # For tiles to appear in the 'Digest email' tab their 'activated_at' time has to be set and correct
    10.times do |i|
      tile = FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", status: Tile::ACTIVE, activated_at: Time.now + i.days
      # Make it so that all odd tiles should be listed before all even ones, and that odd/even each should be sorted in descending order.
      tile.update_attributes(activated_at: tile.activated_at - 2.weeks) if i.even?
    end

    # Make some tiles that should not appear in the 'Digest email' tab...
    # The 'activated_at' times for these tiles are before the 'tile_digest_email_sent_at' => they would have gone out in that batch
    FactoryGirl.create_list :tile, 2, demo: demo, headline: 'I hate Dates and Times', status: Tile::ACTIVE, activated_at: tile_digest_email_sent_at - 1.day

    expected_tile_table =
      [ ["Tile 9", "Tile 7", "Tile 5"],
        ["Tile 3", "Tile 1", "Tile 8"],
        ["Tile 6", "Tile 4", "Tile 2"],
        ["Tile 0"]
      ]

    visit tile_manager_page
    select_tab 'Digest email'

    table_content_without_activation_dates('#digest table').should == expected_tile_table
  end
end
