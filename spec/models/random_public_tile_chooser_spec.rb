require 'spec_helper'

describe RandomPublicTileChooser do
  def rig_rng(expected_limit, values_to_return)
    RandomPublicTileChooser.any_instance.stubs(:rand).with(expected_limit).returns(*values_to_return)
  end

  context '#choose_tile' do
    it "returns a randomly chosen public tile" do
      public_tiles = FactoryGirl.create_list(:multiple_choice_tile, 3, :public).sort_by(&:id)
      expected_offsets = [1, 2, 0, 0, 2, 0]
      rig_rng(3, expected_offsets)

      chooser = RandomPublicTileChooser.new
      expected_offsets.each do |expected_offset|
        chooser.choose_tile.should == public_tiles[expected_offset]
      end
    end
  end
end
