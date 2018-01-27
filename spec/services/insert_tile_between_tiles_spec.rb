require 'spec_helper'

describe InsertTileBetweenTiles do
  def create_tiles number, status
    (0...number).to_a.map do |i|
      FactoryBot.create(:multiple_choice_tile, status, demo: demo, headline: "Tile #{status.to_s} #{i}")
    end
  end

  let(:demo) {FactoryBot.create :demo}

  describe "#insert!" do
    it "should work when inserting between" do
      tiles = create_tiles 4, :draft
      tile = tiles[0]
      left_tile = tiles[3]
      right_tile = tiles[2]
      InsertTileBetweenTiles.new(tile, left_tile.id).insert!
      tile.reload
      expect(tile.prev_tile_in_board).to eq(left_tile)
      expect(tile.next_tile_in_board).to eq(right_tile)
    end

    it "should update positions of tiles to the left" do
      tiles = create_tiles 4, :draft
      tile = tiles[0]
      left_tile = tiles[2]
      InsertTileBetweenTiles.new(tile, left_tile.id).insert!
      tile.reload
      expect(tiles[2].reload.position).to eq(tile.position + 1)
      expect(tiles[3].reload.position).to eq(tile.position + 2)
    end
  end
end
