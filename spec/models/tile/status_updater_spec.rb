require "spec_helper"

describe Tile::StatusUpdater do
  describe ".call" do
    it "initializes a new Tile::StatusUpdater and calls perform" do
      mock_status_updater = OpenStruct.new
      Tile::StatusUpdater.expects(:new).with("tile", "active").returns(mock_status_updater)
      mock_status_updater.expects(:perform)

      Tile::StatusUpdater.call(tile: "tile", new_status: "active")
    end
  end

  describe "#perform" do
    let(:tile) { FactoryBot.create(:tile, status: Tile::DRAFT) }
    it "returns nil if no new status is passed in" do
      updater = Tile::StatusUpdater.new(tile, nil)

      expect(updater.perform).to eq(nil)
      expect(tile.status).to eq(tile.reload.status)
    end

    it "updates statuses" do
      Tile::StatusUpdater.new(tile, Tile::ACTIVE).perform
      expect(tile.status).to eq(Tile::ACTIVE)
      expect(tile.activated_at).to_not eq(nil)

      Tile::StatusUpdater.new(tile, Tile::ARCHIVE).perform
      expect(tile.status).to eq(Tile::ARCHIVE)
      expect(tile.archived_at).to_not eq(nil)

      Tile::StatusUpdater.new(tile, Tile::ACTIVE).perform
      expect(tile.status).to eq(Tile::ACTIVE)
      expect(tile.archived_at).to eq(nil)
    end
  end
end
