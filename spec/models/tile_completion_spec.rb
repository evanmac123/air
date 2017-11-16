require 'spec_helper'

describe TileCompletion do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:tile) }

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
    user_ids.each { |user_id| expect(TileCompletion.user_completed_any_tiles?(user_id, tile_ids)).to be_truthy }

    # Delete the first tile for each user
    [u_1_t_2, u_2_t_1, u_3_t_1].each &:destroy

    # Each user has completed one tile
    user_ids.each { |user_id| expect(TileCompletion.user_completed_any_tiles?(user_id, tile_ids)).to be_truthy }

    u_1_t_3.destroy  # u_1 has not completed any tiles
    user_ids.each do |user_id|
      tile_completed = TileCompletion.user_completed_any_tiles?(user_id, tile_ids)

      if user_id == u_1.id
        expect(tile_completed).to eq(false)
      else
        expect(tile_completed).to eq(true)
      end
    end

    u_2_t_3.destroy  # u_1 and u_2 have not completed any tiles
    user_ids.each do |user_id|
      tile_completed = TileCompletion.user_completed_any_tiles?(user_id, tile_ids)

      if user_id == u_3.id
        expect(tile_completed).to eq(true)
      else
        expect(tile_completed).to eq(false)
      end
    end

    u_3_t_2.destroy  # u_1 and u_2 and u_3 have not completed any tiles
    user_ids.each { |user_id| expect(TileCompletion.user_completed_any_tiles?(user_id, tile_ids)).to be_falsey }
  end
end
