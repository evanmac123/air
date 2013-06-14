require "spec_helper"

include TileHelpers
include EmailHelper

describe 'Digest email' do
  let!(:demo) { FactoryGirl.create :demo, tile_digest_email_sent_at: Date.yesterday }

  before(:each) do
    create_tile headline: 'Phil Kills Kittens'
    create_tile headline: 'Phil Knifes Kittens'
    create_tile headline: 'Phil Kannibalizes Kittens'

    create_tile headline: "Archive Tile", status: Tile::ARCHIVE
  end

  context 'Basic parts' do
    subject { TilesDigestMailer.notify(demo.digest_tiles.pluck(:id)) }

    it { should be_delivered_to 'joe@blow.com' }
    it { should be_delivered_from 'donotreply@hengage.com' }

    it { should have_subject 'Newly-added H.Engage Tiles' }

    it { should have_body_text 'Check out our' }
    it { should have_body_text acts_url(protocol: email_link_protocol, host: email_link_host) }
    it { should have_body_text 'new tiles' }

    it { should have_hengage_footer }
  end

  context 'Tiles' do
    it 'the number and content are correct' do
      # Need to 'deliver' the email so can open and inspect contents with non-email-spec ops
      TilesDigestMailer.notify(demo.digest_tiles.pluck(:id)).deliver
      open_email('joe@blow.com')
      email = current_email

      email.should have_num_tiles(3)

      email.should contain 'Phil Kills Kittens'
      email.should contain 'Phil Knifes Kittens'
      email.should contain 'Phil Kannibalizes Kittens'

      email.should_not contain 'Archive Tile'
    end
  end
end