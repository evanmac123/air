require 'spec_helper'

describe TileLinkTrackingConcern do
  let(:trackable_tile) { FactoryGirl.build(:tile, activated_at: TileLinkTrackingConcern::TILE_LINK_TRACKING_RELEASE_DATE) }

  describe "#track_link_click" do
    it "tracks unique link clicks" do
      user = OpenStruct.new(id: 1)
      link_1 = "test_link_1"
      link_2 = "test_link_2"

      result = ["1", "test_link_2", "1", "test_link_1"]

      trackable_tile.track_link_click(clicked_link: link_1, user: user)
      trackable_tile.track_link_click(clicked_link: link_2, user: user)

      expect(trackable_tile.unique_link_clicks_by_link).to eq(result)

      trackable_tile.track_link_click(clicked_link: link_1, user: user)

      expect(trackable_tile.unique_link_clicks_by_link).to eq(result)
    end

    it "tracks total link clicks" do
      user = OpenStruct.new(id: 1)
      link_1 = "test_link_1"
      link_2 = "test_link_2"

      result_1 = ["1", "test_link_2", "1", "test_link_1"]

      trackable_tile.track_link_click(clicked_link: link_1, user: user)
      trackable_tile.track_link_click(clicked_link: link_2, user: user)

      expect(trackable_tile.link_clicks_by_link).to eq(result_1)

      trackable_tile.track_link_click(clicked_link: link_2, user: user)

      result_2 = ["2", "test_link_2", "1", "test_link_1"]

      expect(trackable_tile.link_clicks_by_link).to eq(result_2)
    end

    it "calls new_unique_link_click?" do
      user = OpenStruct.new(id: 1)
      link_1 = "test_link_1"

      trackable_tile.expects(:new_unique_link_click?).with(link_1, user.id)

      trackable_tile.track_link_click(clicked_link: link_1, user: user)
    end
  end

  describe "#new_unique_link_click?" do
    it "returns true if user is a new unique click" do
      user = OpenStruct.new(id: 1)
      link_1 = "test_link_1"

      expect(trackable_tile.new_unique_link_click?(link_1, user.id)).to eq(true)
    end

    it "stores the unique user id if user is a new unique click" do
      user = OpenStruct.new(id: 1)
      user_2 = OpenStruct.new(id: 2)
      link_1 = "test_link_1"

      trackable_tile.new_unique_link_click?(link_1, user.id)
      trackable_tile.new_unique_link_click?(link_1, user_2.id)
      trackable_tile.new_unique_link_click?(link_1, user_2.id)

      expect(trackable_tile.unique_users_who_clicked(link_1)).to eq(["1", "2"])
    end

    it "returns false if user is not a new unique click" do
      user = OpenStruct.new(id: 1)
      link_1 = "test_link_1"

      trackable_tile.new_unique_link_click?(link_1, user.id)
      expect(trackable_tile.new_unique_link_click?(link_1, user.id)).to eq(false)
    end
  end

  describe "#raw_link_click_stats" do
    it "returns a hash of raw redis sorted set date for unique and total clicks for each link" do
      user = OpenStruct.new(id: 1)
      user_2 = OpenStruct.new(id: 2)
      link_1 = "test_link_1"
      link_2 = "test_link_2"

      trackable_tile.track_link_click(clicked_link: link_1, user: user)
      trackable_tile.track_link_click(clicked_link: link_2, user: user)
      trackable_tile.track_link_click(clicked_link: link_2, user: user_2)

      expect(trackable_tile.raw_link_click_stats).to eq({:unique_link_clicks=>["2", "test_link_2", "1", "test_link_1"], :link_clicks=>["2", "test_link_2", "1", "test_link_1"]})
    end
  end

  describe "#link_click_stats" do
    it "returns a hash with each clicked link as a key and unique and total click counts as values" do
      user = OpenStruct.new(id: 1)
      user_2 = OpenStruct.new(id: 2)
      link_1 = "test_link_1"
      link_2 = "test_link_2"

      trackable_tile.track_link_click(clicked_link: link_1, user: user)
      trackable_tile.track_link_click(clicked_link: link_2, user: user)
      trackable_tile.track_link_click(clicked_link: link_2, user: user_2)

      expect(trackable_tile.link_click_stats).to eq({"test_link_2"=>{:unique_link_clicks=>2, :link_clicks=>2}, "test_link_1"=>{:unique_link_clicks=>1, :link_clicks=>1}})
    end
  end

  describe "#has_link_tracking?" do
    it "returns true if the tile has been activated and if it was activated on or after the TILE_LINK_TRACKING_RELEASE_DATE" do
      expect(trackable_tile.has_link_tracking?).to eq(true)
    end

    it "returns false if the tile was activated before the TILE_LINK_TRACKING_RELEASE_DATE" do
      untrackable_tile = FactoryGirl.build(:tile, activated_at: TileLinkTrackingConcern::TILE_LINK_TRACKING_RELEASE_DATE - 1.day)

      expect(untrackable_tile.has_link_tracking?).to eq(false)
    end

    it "returns false if the tile is not activated" do
      untrackable_tile = FactoryGirl.build(:tile, activated_at: nil)

      expect(untrackable_tile.has_link_tracking?).to eq(false)
    end
  end

  describe "TILE_LINK_TRACKING_RELEASE_DATE" do
    it "is the correct date" do
      expect(TileLinkTrackingConcern::TILE_LINK_TRACKING_RELEASE_DATE).to eq("2017-09-28".to_date)
    end
  end
end
