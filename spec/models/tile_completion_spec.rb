require 'spec_helper'

describe TileCompletion do
  it { should belong_to(:user) }
  it { should belong_to(:tile) }

  context "on create" do
    it "should ping" do
      FakeMixpanelTracker.should be_empty

      tile_completion = FactoryGirl.create(:tile_completion)
      crank_dj_clear

      FakeMixpanelTracker.should have_event_matching('Tile - Completed', {tile_id: tile_completion.tile.id})
    end
  end

  it "should mark all as displayed one final time" do
    @fun = FactoryGirl.create(:demo)
    @leah = FactoryGirl.create(:user, name: 'Leah', demo: @fun)
    @fred = FactoryGirl.create(:user, name: 'Fred', demo: @fun)
    tile = FactoryGirl.create(:tile, demo: @fun)
    completion_leah = FactoryGirl.create(:tile_completion, tile_id: tile.id, user: @leah)
    completion_fred = FactoryGirl.create(:tile_completion, tile_id: tile.id, user: @fred)
    TileCompletion.mark_displayed_one_final_time(@leah)
    completion_leah.reload.displayed_one_final_time.should be_true
    completion_fred.reload.displayed_one_final_time.should be_false
    TileCompletion.already_displayed_one_final_time.count.should == 1
    TileCompletion.already_displayed_one_final_time.first.should == completion_leah
  end

  it '#user_completed_any_tiles? should return true or false depending on whether or not a user has completed any of the tiles' do
    demo = FactoryGirl.create :demo

    u_1 = FactoryGirl.create :user, demo: demo
    u_2 = FactoryGirl.create :user, demo: demo
    u_3 = FactoryGirl.create :user, demo: demo

    t_1 = FactoryGirl.create :tile, demo: demo
    t_2 = FactoryGirl.create :tile, demo: demo
    t_3 = FactoryGirl.create :tile, demo: demo

    # Have u_'n' complete all tiles except t_'n'

    u_1_t_2 = FactoryGirl.create TileCompletion, user: u_1, tile: t_2
    u_1_t_3 = FactoryGirl.create TileCompletion, user: u_1, tile: t_3

    u_2_t_1 = FactoryGirl.create TileCompletion, user: u_2, tile: t_1
    u_2_t_3 = FactoryGirl.create TileCompletion, user: u_2, tile: t_3

    u_3_t_1 = FactoryGirl.create TileCompletion, user: u_3, tile: t_1
    u_3_t_2 = FactoryGirl.create TileCompletion, user: u_3, tile: t_2

    # Grab the user and tile ids and get to work...
    user_ids = User.pluck :id
    tile_ids = Tile.pluck :id

    # Each user has completed two tiles
    user_ids.each { |user_id| TileCompletion.user_completed_any_tiles?(user_id, tile_ids).should be_true }

    # Delete the first tile for each user
    [u_1_t_2, u_2_t_1, u_3_t_1].each &:destroy

    # Each user has completed one tile
    user_ids.each { |user_id| TileCompletion.user_completed_any_tiles?(user_id, tile_ids).should be_true }

    u_1_t_3.destroy  # u_1 has not completed any tiles
    user_ids.each do |user_id|
      tile_completed = TileCompletion.user_completed_any_tiles?(user_id, tile_ids)
      tile_completed.should(user_id == u_1.id ? be_false : be_true)
    end

    u_2_t_3.destroy  # u_1 and u_2 have not completed any tiles
    user_ids.each do |user_id|
      tile_completed = TileCompletion.user_completed_any_tiles?(user_id, tile_ids)
      tile_completed.should(user_id == u_3.id ? be_true : be_false)
    end

    u_3_t_2.destroy  # u_1 and u_2 and u_3 have not completed any tiles
    user_ids.each { |user_id| TileCompletion.user_completed_any_tiles?(user_id, tile_ids).should be_false }
  end
end

