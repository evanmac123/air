require "spec_helper"

describe Tile::StatusUpdater do
  describe ".call" do
    it "initializes a new Tile::StatusUpdater and calls perform" do
      mock_status_updater = OpenStruct.new
      Tile::StatusUpdater.expects(:new).with("tile", "active", false).returns(mock_status_updater)
      mock_status_updater.expects(:perform)

      Tile::StatusUpdater.call(tile: "tile", new_status: "active", redigest: false)
    end
  end

  describe "#perform" do
    let(:tile) { FactoryBot.create(:tile, status: Tile::DRAFT) }
    it "returns nil if no new status is passed in" do
      updater = Tile::StatusUpdater.new(tile, nil, nil)

      expect(updater.perform).to eq(nil)
      expect(tile.status).to eq(tile.reload.status)
    end

    it "updates statuses" do
      Tile::StatusUpdater.new(tile, Tile::ACTIVE, false).perform
      expect(tile.status).to eq(Tile::ACTIVE)

      Tile::StatusUpdater.new(tile, Tile::ARCHIVE, false).perform
      expect(tile.status).to eq(Tile::ARCHIVE)

      Tile::StatusUpdater.new(tile, Tile::ACTIVE, false).perform
      expect(tile.status).to eq(Tile::ACTIVE)

      Tile::StatusUpdater.new(tile, Tile::DRAFT, false).perform
      expect(tile.status).to eq(Tile::DRAFT)
    end

    it "scrubs activated_at when reposting archived tiles and redigesting" do
      Tile::StatusUpdater.new(tile, Tile::ACTIVE, false).perform
      old_activated_at = tile.activated_at
      expect(old_activated_at.present?).to eq(true)

      Tile::StatusUpdater.new(tile, Tile::ARCHIVE, false).perform
      Tile::StatusUpdater.new(tile, Tile::ACTIVE, "true").perform

      expect(tile.activated_at).to_not eq(old_activated_at)
    end

    it "does not scrub activated_at when reposting archived tiles and not redigesting" do
      Tile::StatusUpdater.new(tile, Tile::ACTIVE, false).perform
      old_activated_at = tile.activated_at
      expect(old_activated_at.present?).to eq(true)

      Tile::StatusUpdater.new(tile, Tile::ARCHIVE, false).perform
      Tile::StatusUpdater.new(tile, Tile::ACTIVE, false).perform

      expect(tile.activated_at).to eq(old_activated_at)
    end
  end
end
