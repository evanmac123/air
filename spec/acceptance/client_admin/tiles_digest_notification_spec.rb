require 'acceptance/acceptance_helper'

include EmailHelper

feature 'Client admin and the digest email for tiles' do

  let!(:demo)  { FactoryGirl.create :demo, email: 'foobar@playhengage.com' }
  let!(:admin) { FactoryGirl.create :client_admin, email: 'client-admin@hengage.com', demo: demo }
  before do
    user = FactoryGirl.create :user, demo: demo
    tile = create_tile on_day: '7/5/2013', activated_on: '7/5/2013', status: Tile::ACTIVE, demo: demo, headline: "Tile completed"
    FactoryGirl.create(:tile_completion, tile: tile, user: user)      
  end

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
  end

  # -------------------------------------------------
    
  def have_send_to_selector(selected)
    have_select 'digest[digest_send_to]', {selected: selected}
  end

  def have_follow_up_selector(selected)
    have_select 'digest[follow_up_day]', {selected: selected}
  end

  def change_send_to(send_to)
    select send_to, from: 'digest[digest_send_to]'
  end

  def change_follow_up_day(num_days)
    select num_days, from: 'digest[follow_up_day]'
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
    expect_content_case_insensitive "Email Tiles"
  end

  def expect_no_new_tiles_to_send_header
    expect_content "Send Email with New Tiles"
  end
  
  def expect_digest_sent_content
    expect_content "Your Tiles have been successfully sent. New Tiles you post will appear in the email preview."
  end

  def test_digest_sent_content(email)
    "A test digest email has been sent to #{email}. You should receive it shortly."
  end

  def test_follow_up_sent_content(email)
    "A test follow-up email has been sent to #{email}. You should receive it shortly."
  end

  def follow_up_header_copy
    'SCHEDULED FOLLOW-UP'
  end

  def expect_follow_up_header
    expect_content follow_up_header_copy
  end

  def submit_button
    page.find("#tiles_digest_form input[type='submit']")
  end

# -------------------------------------------------

  context 'No tiles exist for digest email' do
    before(:each) do
      FactoryGirl.create :tile, demo: demo
      visit client_admin_share_path(as: admin)      
    end

    scenario 'Text is correct when no follow-up emails are scheduled to be sent' do
      expect_no_content follow_up_header_copy
    end

    scenario 'Text is correct when follow-up emails are scheduled to be sent, and emails can be cancelled', js: :webkit do  # (Didn't work with poltergeist)
      page.driver.accept_js_confirms!
      create_follow_up_emails
      visit client_admin_share_path(as: admin)

      expect_follow_up_header
      page.should contain 'Monday, July 01, 2013'
      page.should contain 'Tuesday, July 02, 2013'
      page.should contain 'Wednesday, July 03, 2013'
      
      page.all(".cancel_button a").first.click

      
      page.should_not contain 'Monday, July 01, 2013'
      page.should contain 'Tuesday, July 02, 2013'
      page.should contain 'Wednesday, July 03, 2013'
    end

    context "when a followup is cancelled" do
      it "sends a ping", js: :webkit do
        page.driver.accept_js_confirms!
        create_follow_up_emails
        visit client_admin_share_path(as: admin)

        page.all('.cancel_button a').first.click
        FakeMixpanelTracker.clear_tracked_events
        crank_dj_clear

        FakeMixpanelTracker.should have_event_matching('Followup - Cancelled')
      end
    end
  end

  context 'Tiles exist for digest email' do
    scenario "Text is correct" do
      create_tile
      visit client_admin_share_path(as: admin)

      expect_tiles_to_send_header
    end

    scenario 'Form components are on the page and properly initialized', js: true do
      on_day('10/14/2013') do  # Monday
        create_tile
        demo.update_attributes unclaimed_users_also_get_digest: true

        visit client_admin_share_path(as: admin)

        page.should have_send_to_selector('All Users')
        page.should have_follow_up_selector('Thursday')
        expect_character_counter_for '#digest_custom_message', 160
        expect_character_counter_for '#digest_custom_headline', 75
      end

      on_day('10/18/2013') do  # Friday
        create_tile
        demo.update_attributes unclaimed_users_also_get_digest: false

        visit client_admin_share_path(as: admin)

        page.should have_send_to_selector('Activated Users')
        page.should have_follow_up_selector('Tuesday')
        expect_character_counter_for '#digest_custom_message', 160
        expect_character_counter_for '#digest_custom_headline', 75
      end
    end

    scenario 'Text is correct when no follow-up emails are scheduled to be sent' do
      create_tile
      visit client_admin_share_path(as: admin)

      expect_no_content follow_up_header_copy
    end

    scenario 'Text is correct when follow-up emails are scheduled to be sent, and emails can be cancelled', js: :webkit do
      # If you 'create_follow_up_emails' and then 'visit tile_manager_page' the follow-up email creation bombs.
      # We've had this stupid fucking problem before. Luckily Phil figured out it is some kind of timing problem.
      # We've also had the stupid fucking problem of stuff like this not working in poltergeist => have to use webkit
      # (Man, testing is great... but sometimes it can be such a royal fucking pain in the ass)
      page.driver.accept_js_confirms!
      create_tile
      create_follow_up_emails

      visit client_admin_share_path(as: admin)

      expect_follow_up_header
      page.should contain 'Monday, July 01, 2013'
      page.should contain 'Tuesday, July 02, 2013'
      page.should contain 'Wednesday, July 03, 2013'

      page.all('.cancel_button a').first.click

      page.should_not contain 'Monday, July 01, 2013'
      page.should contain 'Tuesday, July 02, 2013'
      page.should contain 'Wednesday, July 03, 2013'
    end

    scenario 'The last-digest-email-sent-on date is correct' do
      create_tile
      visit client_admin_share_path(as: admin)

      expect_no_content 'Last tiles sent on'

      set_last_sent_on '7/4/2013'
      visit client_admin_share_path(as: admin)
      
      expect_content 'Last tiles sent on Thursday, July 04, 2013'
    end

    context "Clicking the 'Send' button" do
      before(:each) do
        set_last_sent_on '7/4/2013'
        2.times { |i| create_tile on_day: '7/5/2013', activated_on: '7/5/2013', status: Tile::ACTIVE, headline: "Headline #{i + 1}"}
      end

      scenario "yet a third message appears, somewhere on the page, that the digest has been sent" do
        visit client_admin_share_path(as: admin)
        submit_button.click
        expect_digest_sent_content
        click_link "Activity"
        should_be_on client_admin_path
      end

      scenario "A confirmation message in modal is displayed,
                and a no-tiles message appears in the Digest tab" do
        on_day '7/6/2013' do
          visit client_admin_share_path(as: admin)
          expect_tiles_to_send_header
          page.should_not contain 'No new tiles have been added'

          submit_button.click
          crank_dj_clear

          expect_digest_sent_content
          page.should_not contain 'Tiles to be sent'
          page.should contain 'No new Tiles to send. Go to Edit to post new Tiles.'
        end
      end

      scenario 'and follow-up can be cancelled immediately' do
        on_day '7/6/2013' do
          visit client_admin_share_path(as: admin)
          change_follow_up_day 'Thursday'
          submit_button.click
          expect_content "Scheduled Follow-Up"
          expect_content "Thursday, July 11, 2013"
        end
      end

      context 'emails are sent to the appropriate people' do
        let (:all_addresses) {%w(client-admin@hengage.com site-admin@hengage.com john@campbell.com irma@thomas.com wc@clark.com taj@mahal.com)}

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
            change_send_to('All Users')
            submit_button.click
            crank_dj_clear
            all_emails.should have(7).emails  # The above 5 for this demo, and the 'client-admin' and the 'user' created at top of tests

            all_addresses.each do |address|
              expect_digest_to(address)

              open_email(address)
              current_email.should have_content "Your New Tiles Are Here!"
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
                page_text_1 = "Welcome to the #{demo.name}!"
                page_text_2 = "Airbo is an interactive communication tool. Get started by clicking on a tile. Interact and answer questions to earn points."
              end

              click_email_link_matching email_link

              page.should have_content page_text_1
              page.should have_content page_text_2
            end
          end
        end

        scenario 'Demo where only claimed users should get digests' do
          on_day '7/6/2013' do
            change_send_to('Activated Users')
            submit_button.click
            crank_dj_clear

            all_emails.should have(4).emails  # 2 claimed users, the 'site-admin', and the 'client-admin' (created at top of tests)

            %w(client-admin@hengage.com wc@clark.com taj@mahal.com).each do |address|
              expect_digest_to(address)
            end
          end
        end

        context "and the optional admin-supplied custom message is filled in" do
          it "should put that in the emails" do
            buzzwordery = "Proactive synergies and cross-functional co-opetition."
            change_send_to('All Users')
            fill_in "digest[custom_message]", with: buzzwordery
            submit_button.click

            crank_dj_clear

            all_addresses.each do |address|
              open_email(address)
              current_email.html_part.body.should include(buzzwordery)
            end
          end
        end

        context "and the optional admin-supplied custom subject is filled in" do
          before do
            @custom_subject = "Pferde in der Wehrmacht waren als Armeepferde ein wichtiger Bestandteil"
            fill_in "digest[custom_subject]", with: @custom_subject
            submit_button.click
          end

          it "uses that" do
            crank_dj_clear

            all_addresses.each do |address|
              open_email(address)
              current_email.subject.should == @custom_subject
            end
          end

          it "records the original subject in the followup" do
            FollowUpDigestEmail.all.length.should == 1
            FollowUpDigestEmail.first.original_digest_subject.should == "#{@custom_subject}"
          end
        end

        context "and the optional admin-supplied custom subject is not filled in" do
          it "uses a reasonable default" do
            submit_button.click

            crank_dj_clear

            all_addresses.each do |address|
              open_email(address)
              current_email.subject.should == "New Tiles"
            end
          end

          it "creates a FollowUpDigestEmail with a nil original subject recorded" do
            submit_button.click
            FollowUpDigestEmail.all.length.should == 1
            FollowUpDigestEmail.first.original_digest_subject.should be_nil
          end
        end

        context "and the optional admin-supplied custom headline is filled in" do
          before do
            @custom_headline = "Do the right thing, you"
            fill_in "digest[custom_headline]", with: @custom_headline
            submit_button.click
            crank_dj_clear
          end

          it "uses that" do
            all_addresses.each do |address|
              open_email(address)
              current_email.html_part.body.should contain(@custom_headline)
              current_email.text_part.body.should contain(@custom_headline)
            end
          end

          it "records that headline in the followup" do
            FollowUpDigestEmail.all.length.should == 1
            FollowUpDigestEmail.first.original_digest_headline.should == @custom_headline
          end
        end

        context "and the optional admin-supplied custom headline is not filled in" do
          it "has a reasonable default" do
            submit_button.click
            crank_dj_clear

            all_addresses.each do |address|
              open_email(address)
              current_email.html_part.body.should contain('Your New Tiles Are Here!')
              current_email.text_part.body.should contain('Your New Tiles Are Here!')
            end
          end
        end
      end

      context "a ping gets sent" do
        it "having the proper label" do
          create_tile
          visit client_admin_share_path(as: admin)
          submit_button.click
          
          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear

          FakeMixpanelTracker.should have_event_matching('Digest - Sent')
        end

        it "recording if the digest is for everyone or just claimed users" do
          create_tile
          visit client_admin_share_path(as: admin)
          select 'All Users', from: 'digest[digest_send_to]'
          submit_button.click

          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear

          FakeMixpanelTracker.should have_event_matching('Digest - Sent', {digest_send_to: 'all users'})

          create_tile
          visit client_admin_share_path(as: admin)
          select 'Activated Users', from: 'digest[digest_send_to]'
          submit_button.click

          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear

          FakeMixpanelTracker.should have_event_matching('Digest - Sent', {digest_send_to: 'only joined users'})
        end

        it "recording if a followup was also scheduled" do
          create_tile
          visit client_admin_share_path(as: admin)
          select "Never", from: 'digest[follow_up_day]'
          submit_button.click

          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear

          FakeMixpanelTracker.should have_event_matching('Digest - Sent', {followup_scheduled: false})

          create_tile
          visit client_admin_share_path(as: admin)
          select "Saturday", from: 'digest[follow_up_day]'
          submit_button.click

          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear

          FakeMixpanelTracker.should have_event_matching('Digest - Sent', {followup_scheduled: true})
        end

        it "recording if an optional message was also added", js: true do
          create_tile
          visit client_admin_share_path(as: admin)
          submit_button.click
          expect_digest_sent_content

          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          FakeMixpanelTracker.should have_event_matching('Digest - Sent', {optional_message_added: false})

          create_tile
          visit client_admin_share_path(as: admin)
          fill_in "digest[custom_message]", with: ''
          submit_button.click
          expect_digest_sent_content

          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          FakeMixpanelTracker.should have_event_matching('Digest - Sent', {optional_message_added: false})

          create_tile
          visit client_admin_share_path(as: admin)
          fill_in "digest[custom_message]", with: 'hey'
          submit_button.click
          expect_digest_sent_content

          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          FakeMixpanelTracker.should have_event_matching('Digest - Sent', {optional_message_added: true})
        end

        it "sends ping for sended new digest email", js:true do
          create_tile
          visit client_admin_share_path(as: admin)
          fill_in "digest[custom_message]", with: ''
          submit_button.click
          expect_digest_sent_content

          FakeMixpanelTracker.clear_tracked_events
          crank_dj_clear
          FakeMixpanelTracker.should have_event_matching('Email Sent', {email_type: "Digest - v. 6/15/14"})
        end

        context "Email Cliked ping" do
          let (:all_addresses) {%w(client-admin@hengage.com site-admin@hengage.com john@campbell.com irma@thomas.com wc@clark.com taj@mahal.com)}

          before do
            FactoryGirl.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
            FactoryGirl.create :user, demo: demo, name: 'Irma Thomas',   email: 'irma@thomas.com'

            FactoryGirl.create :claimed_user, demo: demo, name: 'W.C. Clark', email: 'wc@clark.com'
            FactoryGirl.create :claimed_user, demo: demo, name: 'Taj Mahal',  email: 'taj@mahal.com'

            FactoryGirl.create :site_admin, demo: demo, name: 'Eric Claption',  email: 'site-admin@hengage.com'
          end

          it "sends ping when user click link in email", js: true do
            create_tile
            visit client_admin_share_path(as: admin)
            fill_in "digest[custom_message]", with: ''
            submit_button.click
            expect_digest_sent_content

            crank_dj_clear

            all_addresses.each do |address|
              open_email(address)

              if %w(site-admin@hengage.com wc@clark.com taj@mahal.com).include?(address)  # Claimed, non-client-admin user?
                email_link = /tile_token/
              elsif address == 'client-admin@hengage.com' # client-admin?
                email_link = /acts/
              else
                email_link = /invitations/
              end
              user = User.where(email: address).first
              click_email_link_matching email_link

              ping_message = "Digest - v. 6/15/14"

              FakeMixpanelTracker.clear_tracked_events
              crank_dj_clear
              FakeMixpanelTracker.should have_event_matching('Email clicked', {email_type: ping_message}.merge(user.data_for_mixpanel))
            end
          end
        end
      end
    end
  end

  context "Send test digest or follow-up to self" do
    before do
      create_tile

      FactoryGirl.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
      FactoryGirl.create :user, demo: demo, name: 'Irma Thomas',   email: 'irma@thomas.com'
      FactoryGirl.create :claimed_user, demo: demo, name: 'W.C. Clark', email: 'wc@clark.com'
      FactoryGirl.create :claimed_user, demo: demo, name: 'Taj Mahal',  email: 'taj@mahal.com'
      FactoryGirl.create :site_admin, demo: demo, name: 'Eric Claption',  email: 'site-admin@hengage.com'
      FactoryGirl.create :user,         demo: FactoryGirl.create(:demo)
      FactoryGirl.create :claimed_user, demo: FactoryGirl.create(:demo)

      visit client_admin_share_path(as: admin)

      expect_tiles_to_send_header
    end

    context "test digest" do
      before do
        fill_in "digest[custom_message]", with: 'Custom Message'
        fill_in "digest[custom_subject]", with: 'Custom Subject'
        click_button "Send test email to self"
      end

      it "should send digest only to admin", js: true do
        # don't block anything
        expect_no_content follow_up_header_copy
        expect_no_content 'No new Tiles to send. Go to Edit to post new Tiles.'

        expect_content test_digest_sent_content(admin.email)
        page.find(".close-reveal-modal").click
        # sign out
        page.find("#me_toggle").click
        click_link "Sign Out"
        expect_content "Log In"

        crank_dj_clear
        address = admin.email
        all_emails.should have(1).email

        expect_digest_to(address)

        open_email(address)
        current_email.should have_content "Your New Tiles Are Here!"
        current_email.should have_content 'Custom Message'
        current_email.should have_content 'Custom Subject'

        email_link = /acts/
        click_email_link_matching email_link

        page.should have_content "Log In"
        page.should have_content "REMEMBER ME"
      end

      it "should save entered text in digest form fields", js: true do
        visit client_admin_share_path(as: admin)  

        page.find("#digest_custom_message").value.should == "Custom Message"
        page.find("#digest_custom_subject").value.should == "Custom Subject"
      end
    end

    context "test follow-up" do
      before do
        fill_in "digest[custom_message]", with: 'Custom Message'
        fill_in "digest[custom_subject]", with: 'Custom Subject'
        click_button "Send test follow-up to self"
      end

      it "should send digest only to admin", js: true do
        # don't block anything
        expect_no_content follow_up_header_copy
        expect_no_content 'No new Tiles to send. Go to Edit to post new Tiles.'

        expect_content test_follow_up_sent_content(admin.email)
        page.find(".close-reveal-modal").click
        # sign out
        page.find("#me_toggle").click
        click_link "Sign Out"
        expect_content "Log In"

        crank_dj_clear
        address = admin.email
        all_emails.should have(1).email

        expect_digest_to(address)

        open_email(address)
        current_email.should have_content "Don't miss your new tiles"
        current_email.should have_content 'Custom Message'
        current_email.should have_content 'Custom Subject'

        email_link = /acts/
        click_email_link_matching email_link

        page.should have_content "Log In"
        page.should have_content "REMEMBER ME"
      end

      it "should save entered text in digest form fields", js: true do
        visit client_admin_share_path(as: admin)  

        page.find("#digest_custom_message").value.should == "Custom Message"
        page.find("#digest_custom_subject").value.should == "Custom Subject"
      end
    end
  end
end
