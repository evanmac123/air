require 'spec_helper'

describe InsertTileBetweenTiles do
  def create_tiles number, status
    (0...number).to_a.map do |i|
      FactoryBot.create(:multiple_choice_tile, status, demo: demo, headline: "Tile #{status.to_s} #{i}")
    end
  end

  let(:demo) {FactoryBot.create :demo}

  describe "#insert!" do
    it "should work with left and right tiles" do
      tiles = create_tiles 4, :draft
      tile = tiles[0]
      left_tile = tiles[3]
      right_tile = tiles[2]
      InsertTileBetweenTiles.new(tile.id, left_tile.id, right_tile.id, Tile::DRAFT).insert!
      tile.reload
      expect(tile.prev_tile_in_board).to eq(left_tile)
      expect(tile.next_tile_in_board).to eq(right_tile)
    end

    it "should work with only left tile" do
      tiles = create_tiles 4, :draft
      tile = tiles[3]
      left_tile = tiles[0]
      InsertTileBetweenTiles.new(tile.id, left_tile.id, nil, Tile::DRAFT).insert!
      tile.reload
      expect(tile.prev_tile_in_board).to eq(left_tile)
    end

    it "should work only with right tile" do
      tiles = create_tiles 4, :draft
      tile = tiles[1]
      right_tile = tiles[3]
      InsertTileBetweenTiles.new(tile.id, nil, right_tile.id, Tile::DRAFT).insert!
      tile.reload
      expect(tile.next_tile_in_board).to eq(right_tile)
    end

    it "should work set status if needed" do
      tiles = create_tiles 4, :draft
      tile = FactoryBot.create(:multiple_choice_tile, :active, demo: demo)
      left_tile = tiles[3]
      right_tile = tiles[2]
      InsertTileBetweenTiles.new(tile.id, left_tile.id, right_tile.id, Tile::DRAFT).insert!
      tile.reload
      expect(tile.status).to eq(Tile::DRAFT)
    end

    it "should work if section is empty" do
      tile = FactoryBot.create(:multiple_choice_tile, :active, demo: demo)
      InsertTileBetweenTiles.new(tile.id, nil, nil, Tile::DRAFT).insert!
      tile.reload
      expect(tile.status).to eq(Tile::DRAFT)
      expect(tile.position).to eq(0)
    end

    it "should update positions of tiles to the left" do
      tiles = create_tiles 4, :draft
      tile = tiles[0]
      left_tile = tiles[2]
      right_tile = tiles[1]
      InsertTileBetweenTiles.new(tile.id, left_tile.id, right_tile.id, Tile::DRAFT).insert!
      tile.reload
      expect(tiles[2].reload.position).to eq(tile.position + 1)
      expect(tiles[3].reload.position).to eq(tile.position + 2)
    end
  end
end
