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

    it { should be_delivered_to TilesDigestMailer::TEST_EMAIL }
    it { should be_delivered_from 'donotreply@hengage.com' }

    it { should have_subject 'Newly-added H.Engage Tiles' }

    it { should have_tiles_digest_body_text }

    it { should have_hengage_footer }
  end

  # Different from above because 'email_spec' gem helpers are limited in what they can match in the email
  context 'Tiles and other content' do
    subject do
      # Need to 'deliver' the email so can open and inspect contents with non 'email_spec' gem methods
      TilesDigestMailer.notify(demo.digest_tiles.pluck(:id)).deliver
      open_email(TilesDigestMailer::TEST_EMAIL)
      current_email
    end

      it { should have_num_tiles(3) }
      it { should have_num_tile_image_links(3) }

      it { should contain 'Phil Kills Kittens' }
      it { should contain 'Phil Knifes Kittens' }
      it { should contain 'Phil Kannibalizes Kittens' }

      it { should_not contain 'Archive Tile' }

      it { should have_company_logo_image_link }
      it { should have_view_your_tiles_link }
  end
end
