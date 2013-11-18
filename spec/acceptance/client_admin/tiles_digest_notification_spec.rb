require 'acceptance/acceptance_helper'

include EmailHelper

feature 'Client admin and the digest email for tiles' do

  let(:demo)  { FactoryGirl.create :demo, email: 'foobar@playhengage.com' }
  let(:admin) { FactoryGirl.create :client_admin, email: 'client-admin@hengage.com', demo: demo }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
  end

  # -------------------------------------------------

  def have_send_to_selector(selected)
    have_select 'digest_send_to', {selected: selected}
  end

  def have_follow_up_selector(selected)
    have_select 'follow_up_day', {selected: selected}
  end

  def change_send_to(send_to)
    select send_to, from: 'digest_send_to'
  end

  def change_follow_up_day(num_days)
    select num_days, from: 'follow_up_day'
  end

  def set_last_sent_on(day)
    demo.update_attributes tile_digest_email_sent_at: day_to_time(day)
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

  def expect_tiles_to_send_header
    expect_content "Active tiles to be sent"
  end

  def expect_digest_sent_content
    expect_content "Your tiles have been sent! Now you can monitor the Activity page to see how users interact."
  end
# -------------------------------------------------

  context 'No tiles exist for digest email' do
    before(:each) do
      visit client_admin_share_path(as: admin)
    end

    scenario 'Text is correct' do
      page.should contain 'No digest email is scheduled to be sent because no new tiles have been added'
      page.should_not contain 'since the last one was sent on Thursday, July 04, 2013'

      set_last_sent_on '7/4/2013'
      visit client_admin_share_path(as: admin)

      page.should contain 'since the last one was sent on Thursday, July 04, 2013'
    end

    scenario 'Text and form components are not on the page' do
      page.should_not contain 'Notify users of new tiles'

      page.should_not have_button 'Send digest now'
      page.should_not have_select 'digest_send_to'
      page.should_not have_select 'follow_up_day'
    end

    scenario 'Text is correct when no follow-up emails are scheduled to be sent' do
      expect_no_content 'Scheduled follow-ups'
    end

    scenario 'Text is correct when follow-up emails are scheduled to be sent, and emails can be cancelled', js: :webkit do  # (Didn't work with poltergeist)
      create_follow_up_emails
      visit client_admin_share_path(as: admin)

      page.should contain 'Scheduled follow-ups'
      page.should contain 'Monday, July 01, 2013'
      page.should contain 'Tuesday, July 02, 2013'
      page.should contain 'Wednesday, July 03, 2013'

      first(:link, "Cancel").click

      page.should contain 'Follow-up email for Monday, July 01, 2013 cancelled'
      page.should contain 'Tuesday, July 02, 2013'
      page.should contain 'Wednesday, July 03, 2013'
    end
  end

  context 'Tiles exist for digest email' do
    scenario "Text is correct" do
      create_tile
      visit client_admin_share_path(as: admin)

      page.should contain 'Notify users of new tiles'
      expect_tiles_to_send_header
    end

    scenario 'Form components are on the page and properly initialized' do
      on_day('10/14/2013') do  # Monday
        create_tile
        demo.update_attributes unclaimed_users_also_get_digest: true

        visit client_admin_share_path(as: admin)

        page.should have_send_to_selector('all users')
        page.should have_follow_up_selector('Thursday')
      end

      on_day('10/18/2013') do  # Friday
        create_tile
        demo.update_attributes unclaimed_users_also_get_digest: false

        visit client_admin_share_path(as: admin)

        page.should have_send_to_selector('only joined users')
        page.should have_follow_up_selector('Tuesday')
      end
    end

    scenario 'Text is correct when no follow-up emails are scheduled to be sent' do
      create_tile
      visit client_admin_share_path(as: admin)

      expect_no_content 'Scheduled follow-ups'
    end

    scenario 'Text is correct when follow-up emails are scheduled to be sent, and emails can be cancelled', js: :webkit do
      # If you 'create_follow_up_emails' and then 'visit tile_manager_page' the follow-up email creation bombs.
      # We've had this stupid fucking problem before. Luckily Phil figured out it is some kind of timing problem.
      # We've also had the stupid fucking problem of stuff like this not working in poltergeist => have to use webkit
      # (Man, testing is great... but sometimes it can be such a royal fucking pain in the ass)
      create_tile

      visit client_admin_share_path(as: admin)

      create_follow_up_emails
      visit client_admin_share_path(as: admin)

      page.should contain 'Scheduled follow-ups'
      page.should contain 'Monday, July 01, 2013'
      page.should contain 'Tuesday, July 02, 2013'
      page.should contain 'Wednesday, July 03, 2013'

      first(:link, "Cancel").click

      page.should contain 'Follow-up email for Monday, July 01, 2013 cancelled'
      page.should contain 'Tuesday, July 02, 2013'
      page.should contain 'Wednesday, July 03, 2013'
    end

    scenario 'The last-digest-email-sent-on date is correct' do
      create_tile
      visit client_admin_share_path(as: admin)

      expect_no_content 'Last digest email was sent'

      set_last_sent_on '7/4/2013'
      visit client_admin_share_path(as: admin)

      expect_content 'Last digest email was sent on Thursday, July 04, 2013'
    end

    context "Clicking the 'Send digest now' button" do
      before(:each) do
        set_last_sent_on '7/4/2013'
        2.times { |i| create_tile on_day: '7/5/2013', activated_on: '7/5/2013', status: Tile::ACTIVE, headline: "Headline #{i + 1}"}
      end

      scenario "yet a third message appears, somewhere on the page, that the digest has been sent" do
        visit client_admin_share_path(as: admin)
        click_button "Send digest now"
        expect_digest_sent_content
        click_link "the Activity page"
        should_be_on client_admin_path
      end

      scenario "A flash confirmation message is displayed,
                the last-digest-email-sent-on date is updated,
                and a no-tiles message appears in the Digest tab" do
        on_day '7/6/2013' do
          visit client_admin_share_path(as: admin)
          expect_tiles_to_send_header
          page.should_not contain 'No digest email is scheduled to be sent'

          page.should contain 'Headline 1'
          page.should contain 'Headline 2'

          page.should have_num_tiles(2)

          click_button 'Send digest now'
          crank_dj_clear

          page.should contain "Tiles digest email was sent"

          page.should_not contain 'Tiles to be sent'
          page.should contain 'No digest email is scheduled to be sent'
          page.should contain 'since the last one was sent on Saturday, July 06, 2013'

          page.should_not contain 'Headline 1'
          page.should_not contain 'Headline 2'

          page.should have_num_tiles(0)
        end
      end

      context 'emails are sent to the appropriate people' do
        before do
          FactoryGirl.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
          FactoryGirl.create :user, demo: demo, name: 'Irma Thomas',   email: 'irma@thomas.com'

          FactoryGirl.create :claimed_user, demo: demo, name: 'W.C. Clark', email: 'wc@clark.com'
          FactoryGirl.create :claimed_user, demo: demo, name: 'Taj Mahal',  email: 'taj@mahal.com'

          FactoryGirl.create :site_admin, demo: demo, name: 'Eric Claption',  email: 'site-admin@hengage.com'

          FactoryGirl.create :user,         demo: FactoryGirl.create(:demo)  # Make sure these users from other
          FactoryGirl.create :claimed_user, demo: FactoryGirl.create(:demo)  # demos don't get an email

          visit client_admin_share_path(as: admin)
        end

        scenario "Demo where claimed and unclaimed should get digests.
                  The tile links should sign in claimed, *non-client-admin* users to the
                  Activities page, while whisking others to where they belong" do
          on_day '7/6/2013' do
            change_send_to('all users')
            click_button 'Send digest now'
            crank_dj_clear

            all_emails.should have(6).emails  # The above 5 for this demo, and the 'client-admin' created at top of tests

            %w(client-admin@hengage.com site-admin@hengage.com john@campbell.com irma@thomas.com wc@clark.com taj@mahal.com).each do |address|
              expect_digest_to(address)

              open_email(address)

              name = User.find_by_email(address).first_name
              if %w(site-admin@hengage.com wc@clark.com taj@mahal.com).include?(address)  # Claimed, non-client-admin user?
                email_link = /tile_token/
                page_text_1 = "Welcome back, #{name}"
                page_text_2 = "Invite"
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
          on_day '7/6/2013' do
            change_send_to('only joined users')
            click_button 'Send digest now'
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
      [ ["Tile 9", "Tile 7", "Tile 5", "Tile 3"],
        ["Tile 1", "Tile 8", "Tile 6", "Tile 4"],
        ["Tile 2", "Tile 0"]
      ]

    visit client_admin_share_path(as: admin)

    table_content_without_activation_dates('table').should == expected_tile_table
  end
end
