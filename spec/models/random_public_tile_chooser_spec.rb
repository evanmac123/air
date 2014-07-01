require 'spec_helper'

include RngHelper

describe RandomPublicTileChooser do
  context '#choose_tile' do
    it "returns a randomly chosen public tile" do
      public_tiles = FactoryGirl.create_list(:multiple_choice_tile, 3, :public).sort_by(&:id)
      expected_offsets = [1, 2, 0, 0, 2, 0]
      rig_rng(RandomPublicTileChooser, 3, expected_offsets)

      chooser = RandomPublicTileChooser.new
      expected_offsets.each do |expected_offset|
        chooser.choose_tile.should == public_tiles[expected_offset]
      end
    end
  end
end
