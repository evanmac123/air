require 'spec_helper'

describe Tile::NeighborInBoardFinder do
  let(:demo) { FactoryBot.create(:demo) }

  describe "#next" do
    it "returns itself when only one tile" do
      tile_1 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)
      finder = Tile::NeighborInBoardFinder.new(tile_1)

      expect(finder.next).to eq(tile_1)
    end

    it "returns next tile (first position that's less)" do
      tile_2 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)
      tile_1 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)

      finder = Tile::NeighborInBoardFinder.new(tile_1)

      expect(finder.next).to eq(tile_2)
    end

    it "loops to the beginning" do
      tile_3 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)
      _tile_2 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)
      tile_1 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)

      finder = Tile::NeighborInBoardFinder.new(tile_3)

      expect(finder.next).to eq(tile_1)
    end
  end

  describe "#prev" do
    it "returns itself when only one tile" do
      tile_1 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)
      finder = Tile::NeighborInBoardFinder.new(tile_1)

      expect(finder.prev).to eq(tile_1)
    end

    it "returns prev tile (first position that's greater)" do
      tile_2 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)
      tile_1 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)

      finder = Tile::NeighborInBoardFinder.new(tile_2)

      expect(finder.prev).to eq(tile_1)
    end

    it "loops to the beginning" do
      tile_3 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)
      _tile_2 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)
      tile_1 = FactoryBot.create(:tile, demo: demo, status: Tile::ACTIVE)

      finder = Tile::NeighborInBoardFinder.new(tile_1)

      expect(finder.prev).to eq(tile_3)
    end
  end
end
