require "spec_helper"

include TileHelpers
include EmailHelper

# This spec tests for content (not delivery, which is in /acceptance/client_admin/tiles_digest_notification_spec.rb), so
# it calls 'TilesDigestMailer.notify_one' directly, without delivering the email.
# That method returns a 'mail' object, whose content is then tested.

describe 'Digest email' do
  let(:demo) { FactoryGirl.create :demo, tile_digest_email_sent_at: Date.yesterday }

  let(:claimed_user)   { FactoryGirl.create :claimed_user, demo: demo, name: 'John Campbell', email: 'john@campbell.com' }
  let(:unclaimed_user) { FactoryGirl.create :user,         demo: demo, name: 'Irma Thomas',   email: 'irma@thomas.com'   }

  let(:tile_ids) do
    create_tile headline: 'Phil Kills Kittens'
    create_tile headline: 'Phil Knifes Kittens'
    create_tile headline: 'Phil Kannibalizes Kittens'

    create_tile headline: "Archive Tile", status: Tile::ARCHIVE  # This guy shouldn't show up in the email

    demo.digest_tiles.pluck(:id)
  end

  describe 'Delivery' do
    subject { TilesDigestMailer.notify_one(claimed_user.id, tile_ids) }

    it { should be_delivered_to   'John Campbell <john@campbell.com>' }
    it { should be_delivered_from 'donotreply@hengage.com' }
    it { should have_subject      'New Tiles' }
  end

  describe  'Logo' do
    subject { TilesDigestMailer.notify_one(claimed_user.id, tile_ids) }
    it { should have_selector "a[id $= _logo][target = _blank] img[src ^= http]" }
  end

  describe  'Text' do
    subject { TilesDigestMailer.notify_one(claimed_user.id, tile_ids) }

    it { should have_body_text 'Check out your' }
    it { should have_link 'new tiles' }

    it { should have_body_text 'Interact, earn points, and see how your colleagues are doing!' }
    it { should have_link 'View your tiles' }
  end

  describe  'Links' do
    # There should be 5 links in all: 3 tile links and 2 text links
    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(claimed_user.id, tile_ids) }
      it { should have_selector     "a[href *= 'acts']", count: 5 }
      it { should_not have_selector "a[href *= 'invitations']" }
    end

    # There should be 6 links in all: 5 same as above + 1 for a 'sign up' link in the footer
    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(unclaimed_user.id, tile_ids) }
      it { should have_selector     "a[href *= 'invitations']", count: 6 }
      it { should_not have_selector "a[href *= 'acts']" }
    end
  end

  describe  'Tiles' do
    subject { TilesDigestMailer.notify_one(claimed_user.id, tile_ids) }

    it { should have_num_tiles(3) }
    it { should have_num_tile_image_links(3) }

    it { should have_body_text 'Phil Kills Kittens' }
    it { should have_body_text 'Phil Knifes Kittens' }
    it { should have_body_text 'Phil Kannibalizes Kittens' }

    it { should_not have_body_text 'Archive Tile' }
  end

  describe  'Footer' do
    context 'all users' do
      subject { TilesDigestMailer.notify_one(claimed_user.id, tile_ids) }

      it { should have_body_text 'Copyright &copy; 2013 H.Engage. All Rights Reserved' }
      it { should have_body_text 'Our mailing address is: 222 Newbury St., Floor 3, Boston, MA 02116' }
      it { should have_body_text 'You received this email because your company uses H.Engage' }

      it { should have_link      'Unsubscribe' }
      it { should have_body_text 'from email communications' }
    end

    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(claimed_user.id, tile_ids) }
      it { should     have_link('Update your contact preferences') }
      it { should_not have_link('sign up') }
    end

    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(unclaimed_user.id, tile_ids) }
      it { should_not have_link('Update your contact preferences') }
      it { should     have_link('sign up') }
    end
  end
end
