require 'spec_helper'

describe TileViewing do
  TestAfterCommit.enabled = true
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:tile) }

  describe TileViewing, "#increment" do
    before do
      @tile_viewing = FactoryBot.create(:tile_viewing)
    end

    it "views should = 1 by default" do
      expect(@tile_viewing.views).to eq(1)
    end

    it "should increment views" do
      @tile_viewing.increment
      expect(@tile_viewing.views).to eq(2)
    end
  end

  describe TileViewing, ".add" do
    before do
      @tile = FactoryBot.create(:tile)
      @user = FactoryBot.create(:user)
    end

    it "should create tile viewing or increase views" do
      TileViewing.add(@tile, @user)

      expect(TileViewing.first.views).to eq(1)

      TileViewing.add(@tile, @user)
      tile_viewing = TileViewing.where(tile: @tile, user: @user).first

      expect(tile_viewing.views).to eq(2)
    end

    it "should increase tile's counters" do
      tile = FactoryBot.create(:tile)
      user = FactoryBot.create(:user)
      TileViewing.add(tile, user)
      TileViewing.add(tile, user)

      expect(Tile.find(tile.id).total_views).to eq(2)
      expect(Tile.find(tile.id).unique_views).to eq(1)
    end
  end

  describe TileViewing, ".views" do
    before do
      @tile = FactoryBot.create :tile
      @user = FactoryBot.create :user
    end

    it "should return number of views" do
      expect(TileViewing.views(@tile, @user)).to eq(0)

      TileViewing.add(@tile, @user)
      views = TileViewing.views(@tile, @user)

      expect(views).to eq(1)
    end
  end
end
