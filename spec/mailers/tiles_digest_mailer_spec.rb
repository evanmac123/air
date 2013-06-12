require "spec_helper"

include TileHelpers
include EmailHelper

describe 'Basic parts' do
  subject { TilesDigestMailer.notify(FactoryGirl.create :demo) }

  it { should be_delivered_to 'joe@blow.com' }
  it { should be_delivered_from 'donotreply@hengage.com' }

  it { should have_subject 'Newly-added H.Engage Tiles' }

  it { should have_body_text 'Check out our' }
  it { should have_body_text acts_url(protocol: email_link_protocol, host: email_link_host) }
  it { should have_body_text 'new tiles' }

  it { should have_body_text 'Copyright &copy; 2013 H.Engage. All Rights Reserved' }
  it { should have_body_text 'Our mailing address is: 222 Newbury St., Floor 3, Boston, MA 02116' }
end

describe 'Tiles' do
  let(:demo) { FactoryGirl.create :demo, tile_digest_email_sent_at: Date.yesterday }  # Needed for 'create_tile' helper

  it 'the number and content are correct' do
    create_tile headline: 'Phil Kills Kittens',  start_day: '12/25/2013', end_day: '12/30/2013'
    create_tile headline: 'Phil Knifes Kittens', start_day: '12/25/2013'
    create_tile headline: 'Phil Kannibalizes Kittens'

    create_tile headline: "Old Tile",     created_at: 2.days.ago
    create_tile headline: "Archive Tile", status: Tile::ARCHIVE

    TilesDigestMailer.notify(demo).deliver
    open_email('joe@blow.com')
    email = current_email

    email.should have_num_tiles(3)

    email.should contain 'Phil Kills Kittens'
    email.should contain 'December 25, 2013 - December 30, 2013'

    email.should contain 'Phil Knifes Kittens'
    email.should contain 'December 25, 2013 - Forever'

    email.should contain 'Phil Kannibalizes Kittens'
    email.should contain 'Forever'

    email.should_not contain 'Old Tile'
    email.should_not contain 'Archive Tile'
  end
end
