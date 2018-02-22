require "spec_helper"

include TileHelpers
include EmailHelper

# This spec tests for content (not delivery, which is in /acceptance/client_admin/share/tiles_digest_notification_spec.rb),
# so it calls 'TilesDigestMailer.notify_one' directly, without delivering the email.
# That method returns a 'mail' object, whose content is then tested.

describe 'Digest email' do
  let(:demo) { FactoryBot.create :demo, tile_digest_email_sent_at: Date.yesterday, allow_unsubscribes: true }

# TODO: Using the board_membership factory here is a side effect of how convoluted our factories have become as we've move to using BoardMemberships.  Although there are multiple issues, the particluar issue that necessitated using the board_membership factory is that FactoryBot.create(:claimed_user) creates a user that is 'claimed' in the old sense of the term (i.e. User.activated_at != nil), whereas we now need 'claimed' to mean User.board_membership.joined_board_at != nil. Refactor factories when there is time.

  let!(:claimed_user) do
    user = FactoryBot.create(:claimed_user,
      name: 'John Campbell',
      email: 'john@campbell.com',
      demo: demo
    )

    user.board_memberships.update_all(joined_board_at: Time.current)
    user
  end

  let!(:unclaimed_user) do
    FactoryBot.create(:user,
      name: 'Irma Thomas',
      email: 'irma@thomas.com',
      demo: demo
    )
  end

  let!(:tiles) do
    FactoryBot.create(:tile, demo: demo, headline: 'Headline 1', status: Tile::DRAFT, supporting_content: 'supporting_content_1')

    FactoryBot.create(:tile, demo: demo, headline: 'Headline 2', status: Tile::DRAFT, supporting_content: 'supporting_content_2')

    FactoryBot.create(:tile, demo: demo, headline: 'Headline 3', status: Tile::DRAFT, supporting_content: 'supporting_content_3')

    FactoryBot.create(:tile, demo: demo, headline: "Archive Tile", status: Tile::ARCHIVE)  # This guy shouldn't show up in the email

    demo.tiles
  end

  let(:digest) { TilesDigest.dispatch(demo: demo, sender: claimed_user) }

  describe 'Delivery' do
    subject do
      TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter")
    end

    it { is_expected.to be_delivered_to 'John Campbell <john@campbell.com>' }
    it { is_expected.to be_delivered_from demo.reply_email_address }
    it { is_expected.to have_subject 'New Tiles' }
  end

  describe "X-SMTPAPI Header" do
    it "gets set for TilesDigests" do
      mail = TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter")

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
      mail = TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailFollowUpPresenter")

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
      email = TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter")

      expect(email).to have_selector "img[src $= '/assets/logo.png'][alt = 'Airbo']"
    end

    it "should display another company's logo if they have provided one" do
      demo.logo = File.open(Rails.root.join "spec/support/fixtures/logos/tasty.jpg")
      demo.save
      email = TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter")

      expect(email).to have_selector "img[src *= 'tasty.jpg'][alt = 'Tasty']"
    end
  end

  describe 'Text' do

    context "original digest email should display its title" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter") }

      it { is_expected.to have_link 'Your New Tiles Are Here!' }
      it { is_expected.to have_link 'See Tiles' }
    end

    context "follow-up digest email should display its title" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, "Don't Miss Your New Tiles", "TilesDigestMailFollowUpPresenter") }

      it { is_expected.to have_link "Don't miss your new tiles" }
      it { is_expected.to have_link 'See Tiles' }
    end
  end

  describe 'Links' do
    let(:client_admin) { FactoryBot.create :client_admin, demo: demo }
    let(:site_admin)   { FactoryBot.create :site_admin,   demo: demo }

    # There should be 11 links in all: 9 tile links(3 for each tile) and 2 text links. All links should contain a security token
    # that is used to sign the user in when they click on any of the links in the tile-digest email.
    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter") }
      it { is_expected.to have_selector     "a[href *= 'acts?demo_id=#{demo.id}&email_type=tile_digest&tile_token=#{EmailLink.generate_token(claimed_user)}&user_id=#{claimed_user.id}&tiles_digest_id=#{digest.id}&subject_line=#{URI.escape("New Tiles")}']", count: 11 }
      it { is_expected.not_to have_selector "a[href *= 'invitations']" }
    end

    # There should be 11 links in all same as above
    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(digest, unclaimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter") }
      it { is_expected.to have_selector     "a[href *= 'invitations']", count: 11 }
      it { is_expected.not_to have_selector "a[href *= 'acts']" }
    end

    # client-admins should have the same links as users and access is managed in the controller
    context 'client-admins' do
      subject { TilesDigestMailer.notify_one(digest, client_admin.id, 'New Tiles', "TilesDigestMailDigestPresenter") }
      it { is_expected.to     have_selector "a[href *= 'acts?demo_id=#{demo.id}&email_type=tile_digest&tile_token=#{EmailLink.generate_token(client_admin)}&user_id=#{client_admin.id}&tiles_digest_id=#{digest.id}&subject_line=#{URI.escape("New Tiles")}']", count: 11 }
    end

    # site-admins should have the same links as users and access is managed in the controller
    context 'site-admins' do
      subject { TilesDigestMailer.notify_one(digest, site_admin.id, 'New Tiles', "TilesDigestMailDigestPresenter") }
      it { is_expected.to have_selector "a[href *= 'acts?demo_id=#{demo.id}&email_type=tile_digest&tile_token=#{EmailLink.generate_token(site_admin)}&user_id=#{site_admin.id}&tiles_digest_id=#{digest.id}&subject_line=#{URI.escape("New Tiles")}']", count: 11 }
    end
  end

  describe 'Tiles' do

    subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter") }

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
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter") }

      it { is_expected.not_to have_body_text 'supporting_content_1' }
      it { is_expected.not_to have_body_text 'supporting_content_2' }
      it { is_expected.not_to have_body_text 'supporting_content_3' }
    end

    context "follow-up digest email should display the tile's supporting content" do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, "Don't Miss Your New Tiles", "TilesDigestMailFollowUpPresenter") }

      it { is_expected.to have_body_text 'supporting_content_1' }
      it { is_expected.to have_body_text 'supporting_content_2' }
      it { is_expected.to have_body_text 'supporting_content_3' }
    end
  end

  describe 'Footer' do
    context 'all users' do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter") }

      it { is_expected.to have_body_text "This email is unique for you. Please do not forward it." }
      it { is_expected.to have_body_text 'For assistance contact' }
      it { is_expected.to have_link      'support@airbo.com' }
      it { is_expected.to have_body_text "Our mailing address is #{AIRBO_HQ_STREET}, #{AIRBO_HQ_CITY} #{AIRBO_HQ_STATE} #{AIRBO_HQ_ZIP}" }

      it { is_expected.to have_link      'Unsubscribe' }
      it { is_expected.to have_link 'Update Preferences' }
      it { is_expected.to have_body_text "If using a web browser that's IE8 or below, copy and paste this link into IE8 and above, Firefox or Chrome:" }
    end

    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter") }
      it { is_expected.to     have_link('Update Preferences') }
    end

    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(digest, claimed_user.id, 'New Tiles', "TilesDigestMailDigestPresenter") }
      it { is_expected.not_to have_link('Update preferences') }
    end
  end

  describe 'Digest email tile order' do
    it 'tiles should be sorted by position' do
      # TODO: implement
    end
  end
end
