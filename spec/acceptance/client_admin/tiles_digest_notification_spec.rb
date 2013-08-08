require 'acceptance/acceptance_helper'

include EmailHelper

feature 'Client admin and the digest email for tiles' do

  let(:demo)  { FactoryGirl.create :demo, email: 'foobar@playhengage.com' }
  let(:admin) { FactoryGirl.create :client_admin, email: 'admin@hengage.com', demo: demo }

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

  def change_send_on(day)
    select day, from: 'digest_send_on'
  end

  def set_send_on(day)
    demo.update_attributes tile_digest_email_send_on: day
  end

  def set_last_sent_on(day)
    demo.update_attributes tile_digest_email_sent_at: day_to_time(day)
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
      digest_tab.should have_button 'Send now'

      set_send_on 'Tuesday'
      refresh_tile_manager_page
      select_tab 'Digest email'

      digest_tab.should have_send_on_selector('Tuesday')
    end

    scenario "The 'send-on' dropdown control updates the day and time, and displays a confirmation message", js: true do
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

    scenario 'The last-digest-email-sent-on date is correct' do
      create_tile on_day: '7/5/2013'

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

      scenario 'emails are sent to the appropriate people' do
        FactoryGirl.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
        FactoryGirl.create :user, demo: demo, name: 'Irma Thoman',   email: 'irma@thomas.com'

        FactoryGirl.create :claimed_user, demo: demo, name: 'W.C. Clark', email: 'wc@clark.com'
        FactoryGirl.create :claimed_user, demo: demo, name: 'Taj Mahal',  email: 'taj@mahal.com'

        FactoryGirl.create :user,         demo: FactoryGirl.create(:demo)  # Make sure these users from other
        FactoryGirl.create :claimed_user, demo: FactoryGirl.create(:demo)  # demos don't get an email

        on_day '7/6/2013' do
          visit tile_manager_page
          select_tab 'Digest email'

          click_button 'Send now'
          crank_dj_clear

          all_emails.should have(5).emails  # The above 4 for this demo, and the 'admin' created at top of tests

          %w(admin@hengage.com john@campbell.com irma@thomas.com wc@clark.com taj@mahal.com).each do |address|
            digest_email = find_email(address)
            digest_email.should_not be_nil

            digest_email.from.should have(1).address
            digest_email.from.first.should == demo.email
          end
        end
      end
    end
  end

  it 'Tiles appear in reverse-chronological order by activation-date and then creation-date' do
    # Chronologically-speaking, creating tiles "up" from 0 to 10 and then checking "down" from 10 to 0
    10.times do |i|
      tile = FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", status: Tile::ACTIVE, created_at: Time.now + i.days
      # We now sort by activated_at, and if that time isn't present we fall back on created_at
      # Make it so that all odd tiles should be listed before all even ones, and that odd/even each should be sorted in descending order.
      tile.update_attributes(activated_at: tile.created_at - 2.weeks) if i.even?
    end

    expected_tile_table =
      [ ["Tile 9 Edit Preview", "Tile 7 Edit Preview", "Tile 5 Edit Preview"],
        ["Tile 3 Edit Preview", "Tile 1 Edit Preview", "Tile 8 Edit Preview"],
        ["Tile 6 Edit Preview", "Tile 4 Edit Preview", "Tile 2 Edit Preview"],
        ["Tile 0 Edit Preview"]
      ]

    visit tile_manager_page
    select_tab 'Digest email'

    table_content('#digest table').should == expected_tile_table
  end
end
