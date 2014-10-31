require 'spec_helper'

describe InsertTileBetweenTiles do
  def create_tiles number, status
    (0...number).to_a.map do |i|
      FactoryGirl.create(:multiple_choice_tile, status, demo: demo, headline: "Tile #{status.to_s} #{i}")
    end
  end

  let(:demo) {FactoryGirl.create :demo}

  describe "#insert!" do
    it "should work with left and right tiles" do
      tiles = create_tiles 4, :draft
      tile = tiles[0]
      left_tile = tiles[3]
      right_tile = tiles[2]
      InsertTileBetweenTiles.new(left_tile.id, tile.id, right_tile.id, Tile::DRAFT).insert!
      tile.reload
      tile.left_tile.should == left_tile
      tile.right_tile.should == right_tile
    end

    it "should work with only left tile" do
      tiles = create_tiles 4, :draft
      tile = tiles[3]
      left_tile = tiles[0]
      right_tile = nil
      InsertTileBetweenTiles.new(left_tile.id, tile.id, nil, Tile::DRAFT).insert!
      tile.reload
      tile.left_tile.should == left_tile
      tile.right_tile.should == right_tile
    end

    it "should work only with right tile" do
      tiles = create_tiles 4, :draft
      tile = tiles[1]
      left_tile = nil
      right_tile = tiles[3]
      InsertTileBetweenTiles.new(nil, tile.id, right_tile.id, Tile::DRAFT).insert!
      tile.reload
      tile.left_tile.should == left_tile
      tile.right_tile.should == right_tile
    end

    it "should work set status if needed" do
      tiles = create_tiles 4, :draft
      tile = FactoryGirl.create(:multiple_choice_tile, :active, demo: demo)
      left_tile = tiles[3]
      right_tile = tiles[2]
      InsertTileBetweenTiles.new(left_tile.id, tile.id, right_tile.id, Tile::DRAFT).insert!
      tile.reload
      tile.status.should == Tile::DRAFT
    end

    it "should work if section is empty" do
      tile = FactoryGirl.create(:multiple_choice_tile, :active, demo: demo)
      InsertTileBetweenTiles.new(nil, tile.id, nil, Tile::DRAFT).insert!
      tile.reload
      tile.status.should == Tile::DRAFT
      tile.position.should == 0
    end

    it "should update positions of tiles to the left" do
      tiles = create_tiles 4, :draft
      tile = tiles[0]
      left_tile = tiles[2]
      right_tile = tiles[1]
      InsertTileBetweenTiles.new(left_tile.id, tile.id, right_tile.id, Tile::DRAFT).insert!
      tile.reload
      tiles[2].reload.position.should == tile.position + 1 
      tiles[3].reload.position.should == tile.position + 2
    end
  end
end