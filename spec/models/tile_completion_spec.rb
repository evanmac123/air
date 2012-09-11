require 'spec_helper'

describe TileCompletion do
  it { should belong_to(:user) }
  it { should belong_to(:tile) }

  it "should mark all as displayed one final time" do
    Tile.delete_all
    @fun = FactoryGirl.create(:demo)
    @leah = FactoryGirl.create(:user, name: 'Leah', demo: @fun)
    @fred = FactoryGirl.create(:user, name: 'Fred', demo: @fun)
    tile = FactoryGirl.create(:tile, demo: @fun)
    completion_leah = FactoryGirl.create(:tile_completion, tile_id: tile.id, user_id: @leah.id)
    completion_fred = FactoryGirl.create(:tile_completion, tile_id: tile.id, user_id: @fred.id)
    TileCompletion.mark_displayed_one_final_time(@leah)
    completion_leah.reload.displayed_one_final_time.should be_true
    completion_fred.reload.displayed_one_final_time.should be_false
    TileCompletion.already_displayed_one_final_time.count.should == 1
    TileCompletion.already_displayed_one_final_time.first.should == completion_leah
  end

end

