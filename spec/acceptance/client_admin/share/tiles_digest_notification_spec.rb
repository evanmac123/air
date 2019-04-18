# FIXME: The way time was originally implemted in this spec led to al lot of weird code manually setting created_at and joined_board_at for board_memberships. Rewrite in light of board_memberships and tiles_digest refacotrs so the tests are more straight forward.

require 'acceptance/acceptance_helper'

include EmailHelper

feature 'Client admin and the digest email for tiles' do

  let!(:demo)  { FactoryBot.create :demo, email: 'foobar@playhengage.com' }
  let!(:admin) { FactoryBot.create :client_admin, email: 'client-admin@hengage.com', demo: demo, phone_number: "+3333333333" }

  before do
    on_day '7/5/2013' do
      admin.board_memberships.update_all(created_at: Time.current)
      user = FactoryBot.create :user, demo: demo
      tile = create_tile on_day: '7/5/2013', activated_on: '7/5/2013', status: Tile::DRAFT, demo: demo, headline: "Tile completed"
      FactoryBot.create(:tile_completion, tile: tile, user: user)
    end
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

  def expect_digest_to(recipient)
    digest_email = find_email(recipient)
    expect(digest_email).not_to be_nil

    expect(digest_email.from.size).to eq(1)
    expect(digest_email.from.first).to eq(demo.email)
  end

  def create_follow_up_emails
    digest_1 = TilesDigest.create(demo: user.demo, tile_ids: [1, 2], sender: admin)
    @follow_up_1 = digest_1.create_follow_up_digest_email(
      send_on: Date.new(2013, 7, 1),
      subject: "Subject"
    )

    digest_2 = TilesDigest.create(demo: user.demo, tile_ids: [1, 2], sender: admin)
    @follow_up_1 = digest_2.create_follow_up_digest_email(
      send_on: Date.new(2013, 7, 2),
      subject: "Subject"
    )

    digest_3 = TilesDigest.create(demo: user.demo, tile_ids: [1, 2], sender: admin)
    @follow_up_1 = digest_3.create_follow_up_digest_email(
      send_on: Date.new(2013, 7, 3),
      subject: "Subject"
    )
  end

  def expect_tiles_to_send_header
    expect_content_case_insensitive "Deliver Tiles"
  end

  def expect_no_new_tiles_to_send_header
    expect_content "Send Email with New Tiles"
  end

  def expect_digest_sent_content
    expect_content "Your Tiles have been successfully sent. New Tiles you post will appear in the email preview."
  end

  def test_digest_and_follow_up_sent_content(email)
    "Test Sent"
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
      FactoryBot.create :tile, demo: demo
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
        2.times { |i| create_tile on_day: '7/5/2013', status: Tile::DRAFT, headline: "Headline #{i + 1}"}
      end

      context "subnav notifications" do
        it "shows a notification on the subnav for the reports tab" do
          admin.board_memberships.first.update_attributes(is_client_admin: true)
          visit client_admin_share_path(as: admin)

          submit_button.click

          within "li#board_activity" do
            expect(page).to have_selector("span.badge")
          end
        end
      end

      scenario "yet a third message appears, somewhere on the page, that the digest has been sent" do
        visit client_admin_share_path(as: admin)
        submit_button.click
        expect_digest_sent_content
        click_link "Reports"
        should_be_on client_admin_reports_path
      end

      scenario "A confirmation message in modal is displayed,
                and a no-tiles message appears in the Digest tab" do
        on_day '7/6/2013' do
          visit client_admin_share_path(as: admin)
          expect_tiles_to_send_header

          submit_button.click

          expect_digest_sent_content
          expect(page).not_to contain 'Tiles to be sent'
        end
      end

      scenario 'and follow-up can be cancelled immediately' do
        on_day '7/6/2013' do
          visit client_admin_share_path(as: admin)
          change_follow_up_day 'Thursday'
          submit_button.click
          expect_content "Scheduled Follow-Ups"
          expect_content "Thursday, July 11, 2013"
        end
      end

      context 'emails are sent to the appropriate people' do
        let (:all_addresses) {%w(client-admin@hengage.com site-admin@hengage.com john@campbell.com irma@thomas.com wc@clark.com taj@mahal.com)}

        before do
          on_day '7/5/2013' do
            FactoryBot.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
            FactoryBot.create :user, demo: demo, name: 'Irma Thomas',   email: 'irma@thomas.com'

            FactoryBot.create :claimed_user, demo: demo, name: 'W.C. Clark', email: 'wc@clark.com'
            FactoryBot.create :claimed_user, demo: demo, name: 'Taj Mahal',  email: 'taj@mahal.com'

            FactoryBot.create :site_admin, demo: demo, name: 'Eric Claption',  email: 'site-admin@hengage.com'

            FactoryBot.create :user,         demo: FactoryBot.create(:demo)  # Make sure these users from other
            FactoryBot.create :claimed_user, demo: FactoryBot.create(:demo)  # demos don't get an email
          end

            visit client_admin_share_path(as: admin)
        end

        scenario "Demo where claimed and unclaimed should get digests.
                  The tile links should sign in claimed, *non-client-admin* users to the
                  Activities page, while whisking others to where they belong" do
          on_day '7/6/2013' do
            admin.demo.users.claimed.each do |user|
              user.board_memberships.each { |bm| bm.update_attributes(joined_board_at: Time.current) }
            end
            change_send_to('All Users')
            submit_button.click


            expect(all_emails.size).to eq(7)  # The above 5 for this demo, and the 'client-admin' and the 'user' created at top of tests

            all_addresses.each do |address|
              expect_digest_to(address)

              open_email(address)
              expect(current_email).to have_content "Your New Tiles Are Here!"
              name = User.find_by(email: address).first_name
              if %w(wc@clark.com taj@mahal.com).include?(address)  # Claimed, non-client-admin user?
                email_link = /tile_token/
                page_text_1 = "Welcome back, #{name}"
                page_text_2 = "Invite"
              elsif %w(site-admin@hengage.com client-admin@hengage.com).include?(address)

                if address == 'client-admin@hengage.com'
                  # client-admin was signed in at top of tests and needs to sign out in order to get sent to the Log-In page
                  click_link "Sign Out"
                end

                email_link = /acts/
                page_text_1 = "Sign In"
              else
                email_link = /invitations/
                page_text_1 = demo.name_as_noun
                page_text_2 = demo.intro_message
              end

              click_email_link_matching email_link
              if page_text_1 == "Sign In"
                expect(page).to have_selector('#logoAndNav', visible: false, text: page_text_1)
              else
                expect(page).to have_content page_text_1
              end
            end
          end
        end

        scenario 'Demo where only claimed users should get digests' do
          on_day '7/6/2013' do
            admin.demo.users.claimed.each do |user|
              user.current_board_membership.update_attributes(joined_board_at: Time.current)
            end

            change_send_to('Activated Users')
            submit_button.click


            expect(all_emails.size).to eq(4)  # 2 claimed users, the 'site-admin', and the 'client-admin' (created at top of tests)

            %w(client-admin@hengage.com wc@clark.com taj@mahal.com).each do |address|
              expect_digest_to(address)
            end
          end
        end

        context "when user clicks tile link" do
          it "should log them in a take them to the tile page" do
            submit_button.click
            address = 'wc@clark.com'
            open_email(address)

            click_email_link_matching(/tile_id=/)
            expect(page.current_url.include?("tiles?tile_id=")).to eq(true)
          end
        end

        context "and the optional admin-supplied custom message is filled in" do
          it "should put that in the emails" do
            buzzwordery = "Proactive synergies and cross-functional co-opetition."
            change_send_to('All Users')
            fill_in "digest[custom_message]", with: buzzwordery
            submit_button.click



            all_addresses.each do |address|
              open_email(address)
              expect(current_email.body).to include(buzzwordery)
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


            all_addresses.each do |address|
              open_email(address)
              expect(current_email.subject).to eq(@custom_subject)
            end
          end
        end

        context "and the optional admin-supplied custom subject is not changed" do
          it "defaults to the first tile healine" do
            submit_button.click

            all_addresses.each do |address|
              open_email(address)
              expect(current_email.subject).to eq("Headline 2")
            end
          end
        end

        context "and the optional admin-supplied custom subject is emptied" do
          it "uses a reasonable default" do
            fill_in "digest[custom_subject]", with: ""

            submit_button.click

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

          end

          it "uses that" do
            all_addresses.each do |address|
              open_email(address)
              expect(current_email.body).to contain(@custom_headline)
            end
          end
        end

        context "and the optional admin-supplied custom headline is not filled in" do
          it "has a reasonable default" do
            submit_button.click


            all_addresses.each do |address|
              open_email(address)
              expect(current_email.body).to contain('Your New Tiles Are Here!')
            end
          end
        end
      end

      context "a ping gets sent" do
        it "recording if an optional message was also added", js: true do
          create_tile
          visit client_admin_share_path(as: admin)
          fill_in "digest[custom_message]", with: 'hey'

          accept_alert do
            submit_button.click
          end

          expect_digest_sent_content
        end

        it "sends ping for sended new digest email", js:true do
          create_tile
          visit client_admin_share_path(as: admin)
          fill_in "digest[custom_message]", with: ''

          accept_alert do
            submit_button.click
          end

          expect_digest_sent_content
        end

        context "Email Cliked ping" do
          let (:all_addresses) {%w(client-admin@hengage.com site-admin@hengage.com john@campbell.com irma@thomas.com wc@clark.com taj@mahal.com)}

          before do
            FactoryBot.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
            FactoryBot.create :user, demo: demo, name: 'Irma Thomas',   email: 'irma@thomas.com'

            FactoryBot.create :claimed_user, demo: demo, name: 'W.C. Clark', email: 'wc@clark.com'
            FactoryBot.create :claimed_user, demo: demo, name: 'Taj Mahal',  email: 'taj@mahal.com'

            FactoryBot.create :site_admin, demo: demo, name: 'Eric Claption',  email: 'site-admin@hengage.com'
          end
        end
      end
    end
  end

  context "Send test digest or follow-up to self" do
    before do
      create_tile
      FactoryBot.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
      visit client_admin_share_path(as: admin)
      expect_tiles_to_send_header

      within ".follow_up" do
        find(".dropdown-button-component").click
        find("li", text: "Sunday").click
      end


      fill_in "digest[custom_message]", with: 'Custom Message'
      fill_in "digest[custom_subject]", with: 'Custom Subject'
      click_button "Send Test Messages to Myself"
    end

    it "should send test digest and follow-up only to admin", js: true do
      # don't block anything
      expect_no_content follow_up_header_copy

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
      expect(current_email).to have_content 'Custom Subject'
    end

    it "should save entered text in digest form fields", js: true do
      visit client_admin_share_path(as: admin)

      expect(page).to have_field("Email subject", with: "Custom Subject")
      expect(page).to have_field("Intro message", with: "Custom Message")
    end
  end

  context "when sending a tiles digest with an alternate subject", js: true do
    before do
      visit client_admin_share_path(as: admin)

      fill_in "digest[custom_message]", with: 'Custom Message'
      fill_in "digest[custom_subject]", with: 'Subject'
      fill_in "digest[alt_custom_subject]", with: 'Alt Subject'

      within ".follow_up" do
        find(".dropdown-button-component").click
        find("li", text: "Sunday").click
      end
    end

    describe "when sending test" do
      it "should send three test emails" do
        click_button "Send Test Messages to Myself"

        subjects_sent = ActionMailer::Base.deliveries.map(&:subject)

        expect(subjects_sent.sort).to eq(
          [
            "[Test] Alt Subject",
            "[Test] Don't Miss: Subject / Don't Miss: Alt Subject",
            "[Test] Subject"
          ]
        )
      end
    end

    describe "when sending digest" do
      it "should send with both subjects" do
        accept_alert do
          submit_button.click
        end

        expect_digest_sent_content

        expect(ActionMailer::Base.deliveries.count).to eq(2)

        subjects_sent =  ActionMailer::Base.deliveries.map(&:subject)

        expect(subjects_sent.sort).to eq(["Alt Subject", "Subject"])
      end
    end
  end

  context "when sending a test digest with SMS", js: true do
    before do
      visit client_admin_share_path(as: admin)

      fill_in "digest[custom_subject]", with: 'Subject'
      fill_in "digest[alt_custom_subject]", with: 'Alt Subject'
      check "digest[include_sms]"

      within ".follow_up" do
        find(".dropdown-button-component").click
        find("li", text: "Sunday").click
      end

      click_button "Send Test Messages to Myself"
    end

    it "sends SMS to current_user" do
      expect(FakeTwilio::Client.messages.count).to eq(3)
    end
  end
end
