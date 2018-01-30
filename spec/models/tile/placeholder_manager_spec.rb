require 'spec_helper'

describe Tile::PlaceholderManager do
  describe ".call" do
    it "initializes itself and calls #tiles_with_placeholders" do
      tiles = []
      mock_placeholder_manager = mock("Tile::PlaceholderManager")

      Tile::PlaceholderManager.expects(:new).with(tiles, 4).returns(mock_placeholder_manager)
      mock_placeholder_manager.expects(:tiles_with_placeholders)

      Tile::PlaceholderManager.call(tiles, 4)
    end
  end

  describe "#tiles_with_placeholders" do
    it "returns an empty array if there are no tiles" do
      manager_1 = Tile::PlaceholderManager.new([], 4)
      expect(manager_1.tiles_with_placeholders).to eq([])

      manager_2 = Tile::PlaceholderManager.new([], 6)
      expect(manager_2.tiles_with_placeholders).to eq([])
    end

    describe "when there are 2 tiles and row size is 4" do
      it "returns the correct number of placeholders based on row size and tiles count" do
        manager = Tile::PlaceholderManager.new([Tile.new, Tile.new], 4)
        expectation = ["Tile", "Tile", "Tile::Placeholder", "Tile::Placeholder"]
        result = manager.tiles_with_placeholders.map { |tile| tile.class.to_s }

        expect(result).to eq(expectation)
      end
    end

    describe "when there is 1 tile and row size is 4" do
      it "returns the correct number of placeholders based on row size and tiles count" do
        manager = Tile::PlaceholderManager.new([Tile.new], 4)
        expectation = ["Tile", "Tile::Placeholder", "Tile::Placeholder", "Tile::Placeholder"]
        result = manager.tiles_with_placeholders.map { |tile| tile.class.to_s }

        expect(result).to eq(expectation)
      end
    end

    describe "when there are 3 tiles and row size is 6" do
      it "returns the correct number of placeholders based on row size and tiles count" do
        manager = Tile::PlaceholderManager.new([Tile.new, Tile.new, Tile.new], 6)
        expectation = ["Tile", "Tile", "Tile", "Tile::Placeholder", "Tile::Placeholder", "Tile::Placeholder"]
        result = manager.tiles_with_placeholders.map { |tile| tile.class.to_s }

        expect(result).to eq(expectation)
      end
    end
  end
end
