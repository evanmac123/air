require "spec_helper"

include TileHelpers
include EmailHelper

# This spec tests for content (not delivery, which is in /acceptance/client_admin/share/tiles_digest_notification_spec.rb),
# so it calls 'TilesDigestMailer.notify_one' directly, without delivering the email.
# That method returns a 'mail' object, whose content is then tested.

describe 'Digest email' do
  let(:demo) { FactoryGirl.create :demo, tile_digest_email_sent_at: Date.yesterday, allow_unsubscribes: true }

# TODO: Using the board_membership factory here is a side effect of how convoluted our factories have become as we've move to using BoardMemberships.  Although there are multiple issues, the particluar issue that necessitated using the board_membership factory is that FactoryGirl.create(:claimed_user) creates a user that is 'claimed' in the old sense of the term (i.e. User.activated_at != nil), whereas we now need 'claimed' to mean User.board_membership.joined_board_at != nil. Refactor factories when there is time.

  let!(:claimed_user) do
    user = FactoryGirl.create(:claimed_user,
      name: 'John Campbell',
      email: 'john@campbell.com',
      demo: demo
    )

    user.board_memberships.update_all(joined_board_at: Time.current)
    user
  end

  let!(:unclaimed_user) do
    FactoryGirl.create(:user,
      name: 'Irma Thomas',
      email: 'irma@thomas.com',
      demo: demo
    )
  end

  let(:tiles) do
    FactoryGirl.create(:tile, demo: demo, headline: 'Headline 1', status: Tile::ACTIVE, activated_at: Time.current, supporting_content: 'supporting_content_1')

    FactoryGirl.create(:tile, demo: demo, headline: 'Headline 2', status: Tile::ACTIVE, activated_at: Time.current, supporting_content: 'supporting_content_2')

    FactoryGirl.create(:tile, demo: demo, headline: 'Headline 3', status: Tile::ACTIVE, activated_at: Time.current, supporting_content: 'supporting_content_3')

    FactoryGirl.create(:tile, demo: demo, headline: "Archive Tile", status: Tile::ARCHIVE)  # This guy shouldn't show up in the email

    demo.tiles
  end

  let(:digest) { TilesDigest.create(demo: demo, sender: claimed_user, tiles: tiles, sent_at: Date.current + 2.days) }

  describe 'Delivery' do
    subject do
      TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter)
    end

    it { is_expected.to be_delivered_to 'John Campbell <john@campbell.com>' }
    it { is_expected.to be_delivered_from demo.reply_email_address }
    it { is_expected.to have_subject 'New Tiles' }
  end

  describe "X-SMTPAPI Header" do
    it "gets set for TilesDigests" do
      mail = TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter)

      x_smtpapi_header = JSON.parse(mail.header["X-SMTPAPI"].value)

      custom_unique_args = digest.demo.data_for_mixpanel(user: claimed_user).merge({
        subject: mail.subject,
        digest_id: digest.id,
        email_type: TilesDigestMailDigestPresenter::DIGEST_EMAIL
      }).to_json

      expect(x_smtpapi_header["category"]).to eq(TilesDigestMailDigestPresenter::DIGEST_EMAIL)
      expect(x_smtpapi_header["unique_args"]).to eq(JSON.parse(custom_unique_args))
    end

    it "gets set for FollowUpDigestEmails" do
      mail = TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailFollowUpPresenter)

      x_smtpapi_header = JSON.parse(mail.header["X-SMTPAPI"].value)

      custom_unique_args = digest.demo.data_for_mixpanel(user: claimed_user).merge({
        subject: mail.subject,
        digest_id: digest.id,
        email_type: TilesDigestMailDigestPresenter::FOLLOWUP_EMAIL
      }).to_json

      expect(x_smtpapi_header["category"]).to eq(TilesDigestMailDigestPresenter::FOLLOWUP_EMAIL)
      expect(x_smtpapi_header["unique_args"]).to eq(JSON.parse(custom_unique_args))
    end
  end

  describe 'Logo' do
    it 'should display the HEngage logo and alt-text if an alternative one is not provided' do
      email = TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter)

      expect(email).to have_selector "img[src $= '/assets/airbo_logo_lightblue.png'][alt = 'Airbo']"
    end

    it "should display another company's logo if they have provided one" do
      demo.logo = File.open(Rails.root.join "spec/support/fixtures/logos/tasty.jpg")
      demo.save
      email = TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter)

      expect(email).to have_selector "img[src *= 'tasty.jpg'][alt = 'Tasty']"
    end
  end

  describe 'Text' do

    context "original digest email should display its title" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }

      it { is_expected.to have_link 'Your New Tiles Are Here!' }
      it { is_expected.to have_link 'See Tiles' }
    end

    context "follow-up digest email should display its title" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, "Don't Miss Your New Tiles", TilesDigestMailFollowUpPresenter) }

      it { is_expected.to have_link "Don't miss your new tiles" }
      it { is_expected.to have_link 'See Tiles' }
    end
  end

  describe 'Links' do
    let(:client_admin) { FactoryGirl.create :client_admin, demo: demo }
    let(:site_admin)   { FactoryGirl.create :site_admin,   demo: demo }

    # There should be 11 links in all: 9 tile links(3 for each tile) and 2 text links. All links should contain a security token
    # that is used to sign the user in when they click on any of the links in the tile-digest email.
    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }
      it { is_expected.to have_selector     "a[href *= 'acts?demo_id=#{demo.id}&email_type=tile_digest&tile_token=#{EmailLink.generate_token(claimed_user)}&user_id=#{claimed_user.id}&tiles_digest_id=#{digest.id}&subject_line=#{URI.escape("New Tiles")}']", count: 11 }
      it { is_expected.not_to have_selector "a[href *= 'invitations']" }
    end

    # There should be 11 links in all same as above
    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(digest, unclaimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }
      it { is_expected.to have_selector     "a[href *= 'invitations']", count: 11 }
      it { is_expected.not_to have_selector "a[href *= 'acts']" }
    end

    # client-admins should have the same links as users and access is managed in the controller
    context 'client-admins' do
      subject { TilesDigestMailer.notify_one(digest, client_admin.id, 'New Tiles', TilesDigestMailDigestPresenter) }
      it { is_expected.to     have_selector "a[href *= 'acts?demo_id=#{demo.id}&email_type=tile_digest&tile_token=#{EmailLink.generate_token(client_admin)}&user_id=#{client_admin.id}&tiles_digest_id=#{digest.id}&subject_line=#{URI.escape("New Tiles")}']", count: 11 }
    end

    # site-admins should have the same links as users and access is managed in the controller
    context 'site-admins' do
      subject { TilesDigestMailer.notify_one(digest, site_admin.id, 'New Tiles', TilesDigestMailDigestPresenter) }
      it { is_expected.to have_selector "a[href *= 'acts?demo_id=#{demo.id}&email_type=tile_digest&tile_token=#{EmailLink.generate_token(site_admin)}&user_id=#{site_admin.id}&tiles_digest_id=#{digest.id}&subject_line=#{URI.escape("New Tiles")}']", count: 11 }
    end
  end

  describe 'Tiles' do

    subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }

    it { is_expected.to have_num_tiles(3) }
    it { is_expected.to have_num_tile_links(9) }

    it { is_expected.to have_body_text 'Headline 1' }
    it { is_expected.to have_body_text 'Headline 2' }
    it { is_expected.to have_body_text 'Headline 3' }

    it { is_expected.not_to have_body_text 'Archive Tile' }

    it { is_expected.to have_selector 'td img[alt="Headline 2"]'}
    it { is_expected.to have_selector 'td img[alt="Headline 1"]'}
    it { is_expected.to have_selector 'td img[alt="Headline 3"]'}
  end

  describe 'Supporting Content' do
    context "original digest email should not display the tile's supporting content" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }

      it { is_expected.not_to have_body_text 'supporting_content_1' }
      it { is_expected.not_to have_body_text 'supporting_content_2' }
      it { is_expected.not_to have_body_text 'supporting_content_3' }
    end

    context "follow-up digest email should display the tile's supporting content" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, "Don't Miss Your New Tiles", TilesDigestMailFollowUpPresenter) }

      it { is_expected.to have_body_text 'supporting_content_1' }
      it { is_expected.to have_body_text 'supporting_content_2' }
      it { is_expected.to have_body_text 'supporting_content_3' }
    end
  end

  describe "Link" do
    context "original digest email should not display the tile's link" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }

      it { is_expected.not_to have_link 'http://www.google.com' }
      it { is_expected.not_to have_selector "a[href *= 'http://www.google.com']" }

      it { is_expected.not_to have_link 'https://www.nsa.gov' }
      it { is_expected.not_to have_selector "a[href *= 'https://www.nsa.gov']" }
    end

    context "follow-up digest email should display the tile's link if present" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, "Don't Miss Your New Tiles", TilesDigestMailFollowUpPresenter) }

      it { is_expected.to have_link 'http://www.google.com' }
      it { is_expected.to have_selector "a[href *= 'http://www.google.com']" }

      it { is_expected.to have_link 'https://www.nsa.gov' }
      it { is_expected.to have_selector "a[href *= 'https://www.nsa.gov']" }
    end
  end

  describe 'Footer' do
    context 'all users' do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }

      it { is_expected.to have_body_text "This email is unique for you. Please do not forward it." }
      it { is_expected.to have_body_text 'For assistance contact' }
      it { is_expected.to have_link      'support@airbo.com' }
      it { is_expected.to have_body_text "Our mailing address is #{AIRBO_HQ_STREET}, #{AIRBO_HQ_CITY} #{AIRBO_HQ_STATE} #{AIRBO_HQ_ZIP}" }

      it { is_expected.to have_link      'Unsubscribe' }
      it { is_expected.to have_link 'Update Preferences' }
      it { is_expected.to have_body_text "If using a web browser that's IE8 or below, copy and paste this link into IE8 and above, Firefox or Chrome:" }
    end

    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }
      it { is_expected.to     have_link('Update Preferences') }
    end

    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', TilesDigestMailDigestPresenter) }
      it { is_expected.not_to have_link('Update preferences') }
    end
  end

  describe 'Digest email tile order' do
    it 'tiles should be sorted by position' do
      # TODO: implement
    end
  end

  describe '#notify_all' do
    it 'should not send to a user who is unsubscribed' do
      digest_users = [claimed_user]
      TilesDigestMailer.notify_all(digest)

      expect(ActionMailer::Base.deliveries.count).to eq(digest_users.count)

      ActionMailer::Base.deliveries.clear
      claimed_user.board_memberships.update_all(notification_pref_cd: BoardMembership.notification_prefs[:unsubscribe])
      TilesDigestMailer.notify_all(digest)

      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'should only send to claimed users by default' do
      TilesDigestMailer.notify_all(digest)

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'should only send to claimed and unclaimed_users when the digest specifies to include_unclaimed_users' do
      digest.update_attributes(include_unclaimed_users: true)
      TilesDigestMailer.notify_all(digest)

      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end

    it "should A/B test subject lines if the digest as an alt_subject" do
      digest.update_attributes(include_unclaimed_users: true, subject: "Subject A", alt_subject: "Subject B")

      TilesDigestMailer.notify_all(digest)

      expect(ActionMailer::Base.deliveries.count).to eq(2)
      b_digest = ActionMailer::Base.deliveries.first
      a_digest = ActionMailer::Base.deliveries.last

      expect(a_digest.subject).to eq(digest.subject)
      expect(b_digest.subject).to eq(digest.alt_subject)
    end
  end

  it "should send the appropriate tiles to each user" do
    digest.update_attributes(include_unclaimed_users: true)
    TilesDigestMailer.notify_all(digest)

    expect(ActionMailer::Base.deliveries.size).to eq(2)

    ActionMailer::Base.deliveries.each do |mail|
      demo.tiles.active.each { |t|
        expect(mail.to_s).to contain(t.headline)
      }
    end
  end

  describe "#notify_all_follow_up" do
    it "should send the appropriate tiles to each user" do
      digest.update_attributes(include_unclaimed_users: true)

      digest.create_follow_up_digest_email(send_on: Date.current)

      TilesDigestMailer.notify_all_follow_up

      expect(ActionMailer::Base.deliveries.size).to eq(2)

      ActionMailer::Base.deliveries.each do |mail|
        demo.tiles.active.each { |t|
          expect(mail.to_s).to contain(t.headline)
          expect(mail.to_s).to contain(t.supporting_content)
        }
      end
    end

    it 'should be delivered only to users who did no tiles' do
      demo = FactoryGirl.create :demo
      sender = FactoryGirl.create(:client_admin, demo: demo)

      john = FactoryGirl.create :claimed_user, demo: demo, name: 'John',   email: 'john@beatles.com'
      _paul = FactoryGirl.create :user,         demo: demo, name: 'Paul',   email: 'paul@beatles.com'
      _george = FactoryGirl.create :claimed_user, demo: demo, name: 'George', email: 'george@beatles.com'
      ringo = FactoryGirl.create :user,         demo: demo, name: 'Ringo',  email: 'ringo@beatles.com'

      tiles    = FactoryGirl.create_list :tile, 3, demo: demo
      tile_ids = tiles.collect(&:id)

      digest = TilesDigest.create(demo: demo, sender: sender, tile_ids: tile_ids, sent_at: Time.current, include_unclaimed_users: true)

      digest.create_follow_up_digest_email(send_on: Date.current)

      FactoryGirl.create :tile_completion, user: john,  tile: tiles[0]
      FactoryGirl.create :tile_completion, user: john,  tile: tiles[1]
      FactoryGirl.create :tile_completion, user: ringo, tile: tiles[2]
      FactoryGirl.create :tile_completion, user: sender, tile: tiles[2]

      TilesDigestMailer.notify_all_follow_up

      expect(ActionMailer::Base.deliveries.count).to eq(2)

      recipients = ActionMailer::Base.deliveries.map(&:to).flatten.sort
      subjects = ActionMailer::Base.deliveries.map(&:subject).flatten.uniq

      expect(recipients).to eq(['george@beatles.com', 'paul@beatles.com'])
      expect(subjects).to eq(["Don't Miss: New Tiles"])
    end

    it "should not deliver to users who did not get the original digest" do
      demo = FactoryGirl.create(:demo)

      users_to_deliver_to = FactoryGirl.create_list(:user, 2, demo: demo)

      digest = TilesDigest.create(demo: demo, sender: users_to_deliver_to.first, sent_at: Time.current, tile_ids: [], include_unclaimed_users: true)

      digest.create_follow_up_digest_email(send_on: Date.current)

      _users_to_not_deliver_to = FactoryGirl.create_list(:user, 2, demo: demo)

      TilesDigestMailer.notify_all_follow_up

      delivery_addresses = ActionMailer::Base.deliveries.map(&:to).flatten.sort
      expect(delivery_addresses).to eq(users_to_deliver_to.map(&:email).sort)
    end

    context "when a custom subject is used in the original" do
      it "should base the subject on that" do
        custom_original_digest_subject = "Et tu, Brute?"

        user = FactoryGirl.create(:user)
        tile = FactoryGirl.create(:tile, demo: user.demo)

        digest = TilesDigest.create(demo: user.demo, sender: user, tile_ids: [tile.id], subject: custom_original_digest_subject, include_unclaimed_users: true, sent_at: Time.current)

        digest.create_follow_up_digest_email(
          send_on: Date.current
        )

        TilesDigestMailer.notify_all_follow_up

        open_email(user.email)
        expect(current_email.subject).to eq("Don't Miss: #{custom_original_digest_subject}")
      end
    end

    context "when a custom subject is not used in the original" do
      it "should have a reasonable default" do
        sender = FactoryGirl.create(:client_admin)
        user = FactoryGirl.create(:claimed_user)

        tile = FactoryGirl.create(:tile, demo: user.demo)

        digest = TilesDigest.create(demo: user.demo, sender: sender, tile_ids: [tile.id], include_unclaimed_users: true, sent_at: Time.current)

        digest.create_follow_up_digest_email(
          send_on: Date.current
        )

        TilesDigestMailer.notify_all_follow_up

        open_email(user.email)
        expect(current_email.subject).to eq("Don't Miss: New Tiles")
      end
    end

    context "when a custom headline is used in the original" do
      it "should use the same for the followup" do
        sender = FactoryGirl.create(:client_admin)
        user = FactoryGirl.create(:claimed_user)
        tile = FactoryGirl.create(:tile, demo: user.demo)

        digest = TilesDigest.create(demo: user.demo, sender: sender, tile_ids: [tile.id], headline: 'Kneel before Zod', include_unclaimed_users: true, sent_at: Time.current)

        digest.create_follow_up_digest_email(
          send_on: Date.current
        )

        TilesDigestMailer.notify_all_follow_up

        open_email(user.email)
        expect(current_email.body).to contain('Kneel before Zod')
      end
    end

    context "when a custom headline is not used in the original" do
      it "should have a reasonable default" do
        sender = FactoryGirl.create(:client_admin)
        user = FactoryGirl.create(:claimed_user)
        tile = FactoryGirl.create(:tile, demo: user.demo)

        digest = TilesDigest.create(demo: user.demo, sender: sender, tile_ids: [tile.id], include_unclaimed_users: true, sent_at: Time.current)

        digest.create_follow_up_digest_email(
          send_on: Date.current
        )

        TilesDigestMailer.notify_all_follow_up

        open_email(user.email)
        expect(current_email.body).to contain("Don't miss your new tiles")
      end
    end

    it 'should not send to a user who is unsubscribed' do
      followup_board = FactoryGirl.create(:demo)
      unmuted_user = FactoryGirl.create(:user, demo: followup_board)
      muted_user   = FactoryGirl.create(:user, demo: followup_board)

      muted_user.board_memberships.update_all(notification_pref_cd: BoardMembership.notification_prefs[:unsubscribe])

      digest = TilesDigest.create(demo: followup_board, sender: unmuted_user, tile_ids: [], sent_at: Time.current, include_unclaimed_users: true)

      digest.create_follow_up_digest_email(
        send_on: Date.current,
      )

      TilesDigestMailer.notify_all_follow_up

      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(ActionMailer::Base.deliveries.map(&:to).flatten.first).to eq(unmuted_user.email)
    end
  end
end
