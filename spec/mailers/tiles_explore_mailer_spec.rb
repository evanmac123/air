require "spec_helper"

include TileHelpers
include EmailHelper

describe 'Explore digest email' do
  let(:admin)   { FactoryGirl.create :client_admin, name: 'Robbie Williams', email: 'robbie@williams.com' }

  let(:tile_ids) do
    FactoryGirl.create :tile, :public, headline: 'Phil Kills Kittens',        supporting_content: '6 kittens were killed'
    FactoryGirl.create :tile, :public, headline: 'Phil Knifes Kittens',       supporting_content: '66 kittens were knifed'
    FactoryGirl.create :tile, :public, headline: 'Phil Kannibalizes Kittens', supporting_content: '666 kittens were kannibalized'

    FactoryGirl.create :tile, headline: "Not Public Tile", is_public: false # This guy shouldn't show up in the email

    Tile.viewable_in_public.pluck(:id)
  end
  context "#notify_one_explore" do
    subject { TilesDigestMailer.notify_one_explore(admin.id, tile_ids, 'Test explore digest email', "Heading", "Custom message") }

    describe 'Delivery' do
      it { should be_delivered_to   'Robbie Williams <robbie@williams.com>' }
      it { should be_delivered_from "Airbo <play@ourairbo.com>" }
      it { should have_subject      'Test explore digest email' }
    end

    describe 'Logo. Display the H.Engage logo and alt-text' do
      it { should have_selector "img[src $= '/assets/airbo_logo_lightblue.png'][alt = 'Airbo']" }
    end

    describe "Display its title and button" do
      it { should have_link 'Heading' }
      it { should have_link 'See Tiles' }
      it { should have_body_text "You won't have to log in." }
      it { should_not have_body_text "Works on mobile." }
    end

    describe 'Links' do
      it { should have_selector "a[href *= 'explore?email_type=explore_v_1&explore_token=#{admin.explore_token}']", count: 2 }
      it "should have an explore-token link to each tile" do
        tile_ids.each do |tile_id|
          should have_selector "a[href *= 'explore/tile/#{tile_id}?email_type=explore_v_1&explore_token=#{admin.explore_token}']"
        end
      end
    end

    describe 'Tiles' do
      it { should have_num_tiles(3) }
      it { should have_num_tile_links(3) }

      it { should have_body_text 'Phil Kills Kittens' }
      it { should have_body_text 'Phil Knifes Kittens' }
      it { should have_body_text 'Phil Kannibalizes Kittens' }

      it { should_not have_body_text 'Not Public Tile' }

      it { should have_selector 'td img[alt="Phil Knifes Kittens"]'}
      it { should have_selector 'td img[alt="Phil Kills Kittens"]'}
      it { should have_selector 'td img[alt="Phil Kannibalizes Kittens"]'}
    end

    describe 'Not display the tile supporting content' do
      it { should_not have_body_text '6 kittens were killed' }
      it { should_not have_body_text '66 kittens were knifed' }
      it { should_not have_body_text '666 kittens were kannibalized' }
    end

    describe 'Footer' do
      it { should have_body_text "This email is unique for you. Please do not forward it." }
      it { should have_body_text 'For assistance contact' }
      it { should have_link      'support@air.bo' }
      it { should have_body_text "Our mailing address is 292 Newbury Street, Suite 547, Boston, MA 02116" }

      it { should have_link      'Unsubscribe' }
    end
  end
end
