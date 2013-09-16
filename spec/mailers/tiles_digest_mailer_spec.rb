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
    create_tile headline: 'Phil Kills Kittens',        status: Tile::ACTIVE, activated_at: Time.now, supporting_content: '6 kittens were killed'
    create_tile headline: 'Phil Knifes Kittens',       status: Tile::ACTIVE, activated_at: Time.now, supporting_content: '66 kittens were knifed'
    create_tile headline: 'Phil Kannibalizes Kittens', status: Tile::ACTIVE, activated_at: Time.now, supporting_content: '666 kittens were kannibalized'

    create_tile headline: "Archive Tile", status: Tile::ARCHIVE  # This guy shouldn't show up in the email

    demo.digest_tiles.pluck(:id)
  end

  describe 'Delivery' do
    subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids) }

    it { should be_delivered_to   'John Campbell <john@campbell.com>' }
    it { should be_delivered_from demo.reply_email_address }
    it { should have_subject      'New Tiles' }
  end

  describe 'Logo' do
    it 'should display the H.Engage logo and alt-text if an alternative one is not provided' do
      email = TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids)

      email.should have_selector "img[src $= '/assets/logo.png'][alt = 'H.Engage']"
    end

    it "should display another company's logo if they have provided one, along with default alt-text if they have not provided any" do
      FactoryGirl.create :skin, demo: demo, logo_url: 'http://cannibalism.com/phil.png'
      email = TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids)

      email.should have_selector "img[src = 'http://cannibalism.com/phil.png'][alt = 'Phil']"
    end

    it "should display another company's logo if they have provided one, along with alt-text if they have provided that" do
      FactoryGirl.create :skin, demo: demo, logo_url: 'http://cannibalism.com/phil.png', alt_logo_text: 'Phil is a closet cannibal'
      email = TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids)

      email.should have_selector "img[src = 'http://cannibalism.com/phil.png'][alt = 'Phil is a closet cannibal']"
    end
  end

  describe 'Text' do
    # Note that the bottom text is the same for both original and follow-up

    context "original digest email should display its title" do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids) }

      it { should have_body_text 'Check out your' }
      it { should have_link 'new tiles' }

      it { should have_body_text 'Interact, earn points, and see how your colleagues are doing!' }
      it { should have_link 'View your tiles' }
    end

    context "follow-up digest email should display its title" do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, true) }

      it { should have_body_text 'Did you forget to check out your' }
      it { should have_link 'new tiles' }

      it { should have_body_text 'Interact, earn points, and see how your colleagues are doing!' }
      it { should have_link 'View your tiles' }
    end
  end

  describe 'Links' do
    let(:client_admin) { FactoryGirl.create :client_admin, demo: demo }
    let(:site_admin)   { FactoryGirl.create :site_admin,   demo: demo }

    # There should be 5 links in all: 3 tile links and 2 text links. All links should contain a security token
    # that is used to sign the user in when they click on any of the links in the tile-digest email.
    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids) }
      it { should have_selector     "a[href *= 'acts?tile_token=#{EmailLink.generate_token(claimed_user)}&user_id=#{claimed_user.id}']", count: 5 }
      it { should_not have_selector "a[href *= 'invitations']" }
    end

    # There should be 6 links in all: 5 same as above + 1 for a 'sign up' link in the footer
    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(demo.id, unclaimed_user.id, tile_ids) }
      it { should have_selector     "a[href *= 'invitations']", count: 6 }
      it { should_not have_selector "a[href *= 'acts']" }
    end

    # client-admins should not have automatic sign-in links in their tiles
    context 'client-admins' do
      subject { TilesDigestMailer.notify_one(demo.id, client_admin.id, tile_ids) }
      it { should     have_selector "a[href *= 'acts']", count: 5 }
      it { should_not have_selector "a[href *= 'acts?tile_token']" }
    end

    # site-admins should have automatic sign-in links in their tiles
    context 'site-admins' do
      subject { TilesDigestMailer.notify_one(demo.id, site_admin.id, tile_ids) }
      it { should have_selector "a[href *= 'acts?tile_token=#{EmailLink.generate_token(site_admin)}&user_id=#{site_admin.id}']", count: 5 }
    end
  end

  describe 'Tiles' do
    subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids) }

    it { should have_num_tiles(3) }
    it { should have_num_tile_image_links(3) }

    it { should have_body_text 'Phil Kills Kittens' }
    it { should have_body_text 'Phil Knifes Kittens' }
    it { should have_body_text 'Phil Kannibalizes Kittens' }

    it { should_not have_body_text 'Archive Tile' }

    it { should have_selector 'td img[alt="Phil Knifes Kittens"]'}
    it { should have_selector 'td img[alt="Phil Kills Kittens"]'}
    it { should have_selector 'td img[alt="Phil Kannibalizes Kittens"]'}
  end

  describe 'Supporting Content' do
    context "original digest email should not display the tile's supporting content" do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids) }

      it { should_not have_body_text '6 kittens were killed' }
      it { should_not have_body_text '66 kittens were knifed' }
      it { should_not have_body_text '666 kittens were kannibalized' }
    end

    context "follow-up digest email should display the tile's supporting content" do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, true) }

      it { should have_body_text '6 kittens were killed' }
      it { should have_body_text '66 kittens were knifed' }
      it { should have_body_text '666 kittens were kannibalized' }
    end
  end

  describe 'Footer' do
    context 'all users' do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids) }

      it { should have_body_text 'Copyright &copy; 2013 H.Engage. All Rights Reserved' }
      it { should have_body_text 'Our mailing address is: 222 Newbury St., Floor 3, Boston, MA 02116' }
      it { should have_body_text 'You received this email because your company uses H.Engage' }

      it { should have_link      'Unsubscribe' }
      it { should have_body_text 'from email communications' }
    end

    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids) }
      it { should     have_link('Update your contact preferences') }
      it { should_not have_link('sign up') }
    end

    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(demo.id, unclaimed_user.id, tile_ids) }
      it { should_not have_link('Update your contact preferences') }
      it { should     have_link('sign up') }
    end
  end
end

# Analyzing the email's HTML proved to be a real pain in the you-know-what, so decided that since tests exist
# for tile-order by activation-date, that if we can show that the right methods get called on 'Tile' then
# we can rest assured that the tiles in the email are in the right order.
#
# Need to construct these tests outside the context of the main 'describe' block above because stubbing
# out these methods wreaks havoc with the objects created in the 'let' methods contained within that block.
#
# Also, don't need to test with real data => can just stub out anything that gets called in the process.
# This includes the contents of the digest email itself, which gets rendered as part of the 'view' process.
# Specifically, since we're using plain ol' integers instead of real tiles => give integers (Fixnum) Tile behavior.
#
describe 'Digest email tile order' do
  it 'tiles should be sorted by activation date' do
    Demo.stubs(:find).returns(FactoryGirl.create :demo)
    User.stubs(:find).returns(FactoryGirl.create :claimed_user)

    Fixnum.any_instance.stubs(:headline)
    Fixnum.any_instance.stubs(:thumbnail).returns('xxx')

    tile_ids = [1, 2, 3]

    Tile.expects(:where).with(id: tile_ids).returns(tile_ids)
    tile_ids.expects(:order).with('activated_at DESC').returns(tile_ids)

    TilesDigestMailer.notify_one(1, 2, tile_ids)
  end
end
