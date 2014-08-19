require "spec_helper"

include TileHelpers
include EmailHelper

# This spec tests for content (not delivery, which is in /acceptance/client_admin/tiles_digest_notification_spec.rb),
# so it calls 'TilesDigestMailer.notify_one' directly, without delivering the email.
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

    demo.digest_tiles(nil).pluck(:id)
  end

  describe 'Delivery' do
    subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, 'New Tiles', false, nil) }

    it { should be_delivered_to   'John Campbell <john@campbell.com>' }
    it { should be_delivered_from demo.reply_email_address }
    it { should have_subject      'New Tiles' }
  end

  describe 'Logo' do
    it 'should display the H.Engage logo and alt-text if an alternative one is not provided' do
      email = TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil)

      email.should have_selector "img[src $= '/assets/airbo_logo_lightblue.png'][alt = 'Airbo']"
    end

    it "should display another company's logo if they have provided one, along with default alt-text if they have not provided any" do
      FactoryGirl.create :skin, demo: demo, logo_url: 'http://cannibalism.com/phil.png'
      email = TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil)

      email.should have_selector "img[src = 'http://cannibalism.com/phil.png'][alt = 'Phil']"
    end

    it "should display another company's logo if they have provided one, along with alt-text if they have provided that" do
      FactoryGirl.create :skin, demo: demo, logo_url: 'http://cannibalism.com/phil.png', alt_logo_text: 'Phil is a closet cannibal'
      email = TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil)

      email.should have_selector "img[src = 'http://cannibalism.com/phil.png'][alt = 'Phil is a closet cannibal']"
    end
  end

  describe 'Text' do
    # Note that the bottom text is the same for both original and follow-up

    context "original digest email should display its title" do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil) }

      it { should have_link 'Your New Tiles Are Here!' }
      it { should have_link 'See Tiles' }
    end

    context "follow-up digest email should display its title" do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "Don't Miss Your New Tiles", true, nil) }

      it { should have_link "Don't miss your new tiles" }
      it { should have_link 'See Tiles' }
    end
  end

  describe 'Links' do
    let(:client_admin) { FactoryGirl.create :client_admin, demo: demo }
    let(:site_admin)   { FactoryGirl.create :site_admin,   demo: demo }

    # There should be 5 links in all: 3 tile links and 2 text links. All links should contain a security token
    # that is used to sign the user in when they click on any of the links in the tile-digest email.
    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil) }
      it { should have_selector     "a[href *= 'acts?demo_id=#{demo.id}&email_type=digest_new_v&tile_token=#{EmailLink.generate_token(claimed_user)}&user_id=#{claimed_user.id}']", count: 5 }
      it { should_not have_selector "a[href *= 'invitations']" }
    end

    # There should be 5 links in all same as above
    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(demo.id, unclaimed_user.id, tile_ids, "New Tiles", false, nil) }
      it { should have_selector     "a[href *= 'invitations']", count: 5 }
      it { should_not have_selector "a[href *= 'acts']" }
    end

    # client-admins should not have automatic sign-in links in their tiles
    context 'client-admins' do
      subject { TilesDigestMailer.notify_one(demo.id, client_admin.id, tile_ids, "New Tiles", false, nil) }
      it { should     have_selector "a[href *= 'acts']", count: 5 }
      it { should_not have_selector "a[href *= 'acts?tile_token']" }
    end

    # site-admins should have automatic sign-in links in their tiles
    context 'site-admins' do
      subject { TilesDigestMailer.notify_one(demo.id, site_admin.id, tile_ids, "New Tiles", false, nil) }
      it { should have_selector "a[href *= 'acts?demo_id=#{demo.id}&email_type=digest_new_v&tile_token=#{EmailLink.generate_token(site_admin)}&user_id=#{site_admin.id}']", count: 5 }
    end
  end

  describe 'Tiles' do
    subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil) }

    it { should have_num_tiles(3) }
    it { should have_num_tile_links(3) }

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
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil) }

      it { should_not have_body_text '6 kittens were killed' }
      it { should_not have_body_text '66 kittens were knifed' }
      it { should_not have_body_text '666 kittens were kannibalized' }
    end

    context "follow-up digest email should display the tile's supporting content" do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "Don't Miss Your New Tiles", true, nil) }

      it { should have_body_text '6 kittens were killed' }
      it { should have_body_text '66 kittens were knifed' }
      it { should have_body_text '666 kittens were kannibalized' }
    end
  end

  describe 'Footer' do
    context 'all users' do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil) }

      it { should have_body_text 'For assistance contact' }
      it { should have_link      'support@air.bo' }
      it { should have_body_text "We're located at 222 Newbury St, Boston, MA 02116" }

      it { should have_link      'Unsubscribe' }
      it { should have_link 'Update Preferences' }
    end

    context 'claimed user' do
      subject { TilesDigestMailer.notify_one(demo.id, claimed_user.id, tile_ids, "New Tiles", false, nil) }
      it { should     have_link('Update Preferences') }
    end

    context 'unclaimed user' do
      subject { TilesDigestMailer.notify_one(demo.id, unclaimed_user.id, tile_ids, "New Tiles", false, nil) }
      it { should_not have_link('Update preferences') }
    end
  end
end

# Analyzing the email's HTML proved to be a real pain in the you-know-what, so decided that since tests exist
# for tile-order by activation-date, that if we can show that the right methods get called on 'Tile' then
# we can rest assured that the tiles in the email are in the right order.
#
# Need to construct these tests outside the context of the main 'describe' block above because stubbing
# the methods that we need to wreaks havoc with the objects created in the 'let' methods contained within that block.
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
    Fixnum.any_instance.stubs(:points)
    Fixnum.any_instance.stubs(:question).returns("dcsddsc")
    Fixnum.any_instance.stubs(:thumbnail).returns('xxx')

    tile_ids = [1, 2, 3]

    Tile.expects(:where).with(id: tile_ids).returns(tile_ids)
    tile_ids.expects(:order).with('activated_at DESC').returns(tile_ids)

    TilesDigestMailer.notify_one(1, 2, tile_ids, "New Tiles", false, nil)
  end
end

describe '#notify_all' do
  it 'should not send to a user with digests muted' do
    demo = FactoryGirl.create(:demo)
    user = FactoryGirl.create(:user)
    user.add_board(demo)
    user.board_memberships.find_by_demo_id(demo.id).update_attributes(digest_muted: true)

    crank_dj_clear
    ActionMailer::Base.deliveries.clear

    TilesDigestMailer.notify_all(demo, true, [], "a custom message", "a subject")
    crank_dj_clear

    ActionMailer::Base.deliveries.should be_empty
  end
end

describe '#notify_all_follow_up' do
  it 'should be delivered to the appropriate people' do
    demo = FactoryGirl.create :demo

    john   = FactoryGirl.create :claimed_user, demo: demo, name: 'John',   email: 'john@beatles.com'
    paul   = FactoryGirl.create :user,         demo: demo, name: 'Paul',   email: 'paul@beatles.com'
    george = FactoryGirl.create :claimed_user, demo: demo, name: 'George', email: 'george@beatles.com'
    ringo  = FactoryGirl.create :user,         demo: demo, name: 'Ringo',  email: 'ringo@beatles.com'

    tiles    = FactoryGirl.create_list :tile, 3, demo: demo
    tile_ids = tiles.collect(&:id)

    follow_up = FactoryGirl.create :follow_up_digest_email, demo: demo, tile_ids: tile_ids, unclaimed_users_also_get_digest: true, send_on: Date.today

    FactoryGirl.create :tile_completion, user: john,  tile: tiles[0]
    FactoryGirl.create :tile_completion, user: john,  tile: tiles[1]
    FactoryGirl.create :tile_completion, user: ringo, tile: tiles[2]

    # Make sure that only paul and george receive follow-up emails
    object = mock('delay')
    TilesDigestMailer.stubs(:delay).returns(object)

    object.expects(:notify_one).at_most(2)
    object.expects(:notify_one).with(demo.id, paul.id,   tile_ids, "Don't Miss Your New Tiles", true, nil)
    object.expects(:notify_one).with(demo.id, george.id, tile_ids, "Don't Miss Your New Tiles", true, nil)

    # Make sure we delete 'FollowUpDigestEmail' objects after we process them
    FollowUpDigestEmail.expects(:find).returns(follow_up)
    follow_up.expects(:destroy)

    TilesDigestMailer.notify_all_follow_up follow_up.id
  end

  it 'should not send to a user with followups muted' do
    unmuted_user = FactoryGirl.create(:user, :claimed)
    muted_user   = FactoryGirl.create(:user, :claimed)
    followup_board = FactoryGirl.create(:demo)
    [unmuted_user, muted_user].each {|user| user.add_board(followup_board)}
    muted_user.board_memberships.where(demo_id: followup_board.id).first.update_attributes(followup_muted: true)

    follow_up = FactoryGirl.create :follow_up_digest_email, demo: followup_board, tile_ids: [], send_on: Date.today

    TilesDigestMailer.notify_all_follow_up follow_up.id
    crank_dj_clear

    ActionMailer::Base.deliveries.should have(1).followups
    ActionMailer::Base.deliveries.map(&:to).flatten.first.should == unmuted_user.email
  end
end

describe "#notify_one" do
  it "should not try to send to a blank or nil address" do
    blank_mail_user = FactoryGirl.create(:user, email: '')
    nil_mail_user   = FactoryGirl.create(:user, email: nil)

    blank_mail = TilesDigestMailer.notify_one(blank_mail_user.demo.id, blank_mail_user.id, [], 'New Tiles', false, nil)
    nil_mail = TilesDigestMailer.notify_one(nil_mail_user.demo.id, nil_mail_user.id, [], 'New Tiles', false, nil)

    blank_mail.should be_kind_of(ActionMailer::Base::NullMail)
    nil_mail.should be_kind_of(ActionMailer::Base::NullMail)
  end
end

describe "#notify_one_explore" do
  it "should use the proper URL in the text part" do
    user = FactoryGirl.create(:user)
    tile = FactoryGirl.create(:tile)

    mail = TilesDigestMailer.notify_one_explore(user.id, [tile.id], "subject", "heading", "message")
    text = mail.text_part.to_s

    text.should include(explore_path(explore_token: user.explore_token))
    text.should include(explore_tile_preview_path(id: tile.id, explore_token: user.explore_token))
  end
end
