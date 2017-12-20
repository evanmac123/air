require 'spec_helper'

describe BoardCopier do
  describe "#copy_active_tiles_from_board" do
    let(:orignal_board)  { FactoryBot.create(:demo, name: "Original Board") }
    let(:new_board)      { FactoryBot.create(:demo, name: "New Board") }

    describe "#copy_active_tiles_from_board" do
      let(:board_copier) { BoardCopier.new(new_board, orignal_board) }

      it "instantiates a new TileCopier for each active tile" do
        active_tiles = FactoryBot.create_list(:tile, 3, demo: orignal_board, status: Tile::ACTIVE)
        draft_tile = FactoryBot.create(:tile, demo: orignal_board, status: Tile::DRAFT)
        archive_tile = FactoryBot.create(:tile, demo: orignal_board, status: Tile::ARCHIVE)

        tile_copier_mock = stub_everything

        active_tiles.each do |tile|
          TileCopier.expects(:new).with(new_board, tile).returns(tile_copier_mock)
        end

        TileCopier.expects(:new).with(new_board, draft_tile).never
        TileCopier.expects(:new).with(new_board, archive_tile).never

        board_copier.copy_active_tiles_from_board
      end

      it "copies each active tile to new board" do
        FactoryBot.create_list(:tile, 3, demo: orignal_board, status: Tile::ACTIVE)

        TileCopier.any_instance.expects(:copy_from_own_board).with(Tile::ACTIVE, "Initial Board Setup").times(3)

        board_copier.copy_active_tiles_from_board
      end
    end
  end
end
