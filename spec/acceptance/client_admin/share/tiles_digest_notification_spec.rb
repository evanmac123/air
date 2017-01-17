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
    expect(digest_email).not_to be_nil

    expect(digest_email.from.size).to eq(1)
    expect(digest_email.from.first).to eq(demo.email)
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

  def test_digest_and_follow_up_sent_content(email)
    "A test Tiles Email and Follow-up Email has been sent to #{email}. You should receive it shortly."
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
  end

  context 'Tiles exist for digest email' do
    scenario "Text is correct" do
      create_tile
      visit client_admin_share_path(as: admin)

      expect_tiles_to_send_header
    end

    scenario 'Text is correct when no follow-up emails are scheduled to be sent' do
      create_tile
      visit client_admin_share_path(as: admin)

      expect_no_content follow_up_header_copy
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
          expect(page).not_to contain 'No new tiles have been added'

          submit_button.click
          crank_dj_clear

          expect_digest_sent_content
          expect(page).not_to contain 'Tiles to be sent'
          expect(page).to contain 'No new Tiles to send. Go to Edit to post new Tiles.'
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
            admin.demo.users.claimed.each do |user|
              user.board_memberships.each { |bm| bm.update_attributes(joined_board_at: Time.now) }
            end

            change_send_to('All Users')
            submit_button.click
            crank_dj_clear
            expect(all_emails.size).to eq(7)  # The above 5 for this demo, and the 'client-admin' and the 'user' created at top of tests

            all_addresses.each do |address|
              expect_digest_to(address)

              open_email(address)
              expect(current_email).to have_content "Your New Tiles Are Here!"
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

              expect(page).to have_content page_text_1
              expect(page).to have_content page_text_2
            end
          end
        end

        scenario 'Demo where only claimed users should get digests' do
          on_day '7/6/2013' do
            admin.demo.users.claimed.each do |user|
              user.current_board_membership.update_attributes(joined_board_at: Time.now)
            end

            change_send_to('Activated Users')
            submit_button.click
            crank_dj_clear

            expect(all_emails.size).to eq(4)  # 2 claimed users, the 'site-admin', and the 'client-admin' (created at top of tests)

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
              expect(current_email.html_part.body).to include(buzzwordery)
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
              expect(current_email.subject).to eq(@custom_subject)
            end
          end
        end

        context "and the optional admin-supplied custom subject is not filled in" do
          it "uses a reasonable default" do
            submit_button.click

            crank_dj_clear

            all_addresses.each do |address|
              open_email(address)
              expect(current_email.subject).to eq("New Tiles")
            end
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
              expect(current_email.html_part.body).to contain(@custom_headline)
              expect(current_email.text_part.body).to contain(@custom_headline)
            end
          end
        end

        context "and the optional admin-supplied custom headline is not filled in" do
          it "has a reasonable default" do
            submit_button.click
            crank_dj_clear

            all_addresses.each do |address|
              open_email(address)
              expect(current_email.html_part.body).to contain('Your New Tiles Are Here!')
              expect(current_email.text_part.body).to contain('Your New Tiles Are Here!')
            end
          end
        end
      end

      context "a ping gets sent" do
        it "recording if an optional message was also added", js: true do
          create_tile
          visit client_admin_share_path(as: admin)
          submit_button.click
          #expect_digest_sent_content

          create_tile
          visit client_admin_share_path(as: admin)
          fill_in "digest[custom_message]", with: ''
          submit_button.click
          #expect_digest_sent_content

          create_tile
          visit client_admin_share_path(as: admin)
          fill_in "digest[custom_message]", with: 'hey'
          submit_button.click
          expect_digest_sent_content
        end

        it "sends ping for sended new digest email", js:true do
          create_tile
          visit client_admin_share_path(as: admin)
          fill_in "digest[custom_message]", with: ''
          submit_button.click
          expect_digest_sent_content
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
        end
      end
    end
  end

  context "Send test digest or follow-up to self" do
    before do
      create_tile
      FactoryGirl.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
      visit client_admin_share_path(as: admin)
      expect_tiles_to_send_header

      within ".follow_up" do
        find(".drop_down").click
        find("li", text: "Sunday").click
      end


      fill_in "digest[custom_message]", with: 'Custom Message'
      fill_in "digest[custom_subject]", with: 'Custom Subject'
      click_button "Send a Test Email to Myself"
    end

    it "should send test digest and follow-up only to admin", js: true do
      # don't block anything
      expect_no_content follow_up_header_copy
      expect_no_content 'No new Tiles to send. Go to Edit to post new Tiles.'

      expect_content test_digest_and_follow_up_sent_content(admin.email)
      page.find(".close-reveal-modal").click
      # sign out
      page.find("#me_toggle").click
      click_link "Sign Out"
      expect_content "Log In"

      crank_dj_clear
      address = admin.email
      expect(all_emails.size).to eq(2)

      expect_digest_to(address)
      # digest
      open_email(address, with_subject: "[Test] Custom Subject")
      expect(current_email).to have_content "Your New Tiles Are Here!"
      expect(current_email).to have_content 'Custom Message'
      expect(current_email).to have_content 'Custom Subject'
      # follow up
      open_email(address, with_subject: "[Test] Don't Miss: Custom Subject")
      expect(current_email).to have_content "Don't miss your new tiles"
      expect(current_email).to have_content 'Custom Message'
      expect(current_email).to have_content 'Custom Subject'

      email_link = /acts/
      click_email_link_matching email_link

      expect(page).to have_content "Log In"
      expect_content "REMEMBER ME"
    end

    it "should save entered text in digest form fields", js: true do
      visit client_admin_share_path(as: admin)

      expect(page).to have_field("Email subject", with: "Custom Subject")
      expect(page).to have_field("Intro message", with: "Custom Message")
    end
  end
end
