require "spec_helper"

include TileHelpers

describe 'Follow-up email scheduled by delayed job' do

  it "should send the appropriate tiles the first time a digest is sent per demo too" do
    demo = FactoryGirl.create(:demo)
    expect(demo.tile_digest_email_sent_at).to be_nil

    FactoryGirl.create :tile, headline: "Tile the first", status: Tile::ACTIVE, demo: demo
    FactoryGirl.create :tile, headline: "Tile the second", status: Tile::ACTIVE, demo: demo

    expect(demo.active_tiles.size).to eq(2)

    FactoryGirl.create_list(:user, 3, :claimed, demo: demo)

    demo.users.claimed.each do |user|
      user.current_board_membership.update_attributes(joined_board_at: Time.now)
    end

    TilesDigestMailer.notify_all(demo, demo.users.claimed.pluck(:id), [demo.tiles.pluck(:id)], nil, nil, nil)

    expect(ActionMailer::Base.deliveries.size).to eq(3)
    ActionMailer::Base.deliveries.each do |mail|
      expect(mail.to_s).to contain("Tile the first")
      expect(mail.to_s).to contain("Tile the second")
    end
  end
end
