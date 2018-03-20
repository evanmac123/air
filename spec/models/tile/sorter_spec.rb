require 'spec_helper'

describe Tile::Sorter do

  describe ".call" do
    let(:tile) { FactoryBot.create(:tile) }

    it "initializes a Tile::Sorter and calls perform with left_tile_id" do
      mock_tile_sorter = OpenStruct.new

      Tile::Sorter.expects(:new).with(tile, 2).returns(mock_tile_sorter)
      mock_tile_sorter.expects(:perform)

      Tile::Sorter.call(tile: tile, left_tile_id: 2 )
    end

    it "initializes a Tile::Sorter and calls perform with no left_tile_id" do
      mock_tile_sorter = OpenStruct.new

      Tile::Sorter.expects(:new).with(tile, nil).returns(mock_tile_sorter)
      mock_tile_sorter.expects(:perform)

      Tile::Sorter.call(tile: tile)
    end
  end

  describe "#perform" do
    let(:demo)  { FactoryBot.create :demo }

    it "should inserting between" do
      tiles = FactoryBot.create_list(:tile, 4, demo: demo)
      tile = tiles[0]
      left_tile = tiles[3]
      right_tile = tiles[2]
      Tile::Sorter.new(tile, left_tile.id).perform

      expect(tile.prev_tile_in_board).to eq(left_tile)
      expect(tile.next_tile_in_board).to eq(right_tile)
    end

    it "should insert in first position without a left_tile_id" do
      _tiles = FactoryBot.create_list(:tile, 4, demo: demo)
      tile_order = demo.tiles.active.order(position: :desc).pluck(:id)
      last_tile_id = tile_order.last

      Tile::Sorter.new(Tile.find(last_tile_id), nil).perform

      expected_tile_order = tile_order[0..2].unshift(last_tile_id)
      new_tile_order = demo.tiles.active.order(position: :desc).pluck(:id)

      expect(expected_tile_order).to eq(new_tile_order)
    end

    it "should update positions of tiles to the left" do
      tiles = FactoryBot.create_list(:tile, 4, demo: demo)
      tile = tiles[0]
      left_tile = tiles[2]
      Tile::Sorter.new(tile, left_tile.id).perform

      expect(tiles[2].reload.position).to eq(tile.position + 1)
      expect(tiles[3].reload.position).to eq(tile.position + 2)
    end
  end
end
