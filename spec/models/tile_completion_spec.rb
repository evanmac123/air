require 'spec_helper'

describe TileCompletion do
  it { should belong_to(:user) }
  it { should belong_to(:tile) }

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

  it "should change new creator's flag has_own_tile_completed to true" do
    client = FactoryGirl.create :client_admin
    user = FactoryGirl.create :user
    client.has_own_tile_completed.should be_false

    tile = FactoryGirl.create :tile, creator_id: client.id
    client.reload.has_own_tile_completed.should be_false

    tc = FactoryGirl.create(:tile_completion, tile_id: tile.id, user: user)
    client.reload.has_own_tile_completed.should be_true
    client.has_own_tile_completed_displayed.should be_false
    client.has_own_tile_completed_id.should eq(tile.id)
  end

  describe TileCompletion, ".non_completions_with_users" do
    before do
      @demo1 = FactoryGirl.create :demo
      @demo2 = FactoryGirl.create :demo

      @u1 = FactoryGirl.create :user, demo: @demo1
      @u2 = FactoryGirl.create :user, demo: @demo1
      @u3 = FactoryGirl.create :user, demo: @demo2

      @t = FactoryGirl.create :tile, demo: @demo1

      @t_c = FactoryGirl.create :tile_completion, tile: @t, user: @u1
    end

    it "should return only users from current board that didn't complete the tile" do
      users = TileCompletion.non_completions_with_users @t
      users.should include(@u2)
      users.should_not include(@u1, @u3)
    end
  end

  describe TileCompletion, ".tile_completions_with_users" do
    before do
      @demo1 = FactoryGirl.create :demo
      @demo2 = FactoryGirl.create :demo

      @u1 = FactoryGirl.create :user, demo: @demo1
      @u2 = FactoryGirl.create :user, demo: @demo1
      @u3 = FactoryGirl.create :user, demo: @demo2

      @gu1 = FactoryGirl.create :guest_user, demo: @demo1
      @gu2 = FactoryGirl.create :guest_user, demo: @demo1
      @gu3 = FactoryGirl.create :guest_user, demo: @demo2

      @t1 = FactoryGirl.create :tile, demo: @demo1
      @t2 = FactoryGirl.create :tile, demo: @demo1
      @t3 = FactoryGirl.create :tile, demo: @demo2

      @t_c1 = FactoryGirl.create :tile_completion, tile: @t1, user: @u1
      @t_c2 = FactoryGirl.create :tile_completion, tile: @t2, user: @u2
      @t_c3 = FactoryGirl.create :tile_completion, tile: @t3, user: @u3

      @t_c4 = FactoryGirl.create :tile_completion, tile: @t1, user: @gu1
      @t_c5 = FactoryGirl.create :tile_completion, tile: @t2, user: @gu2
      @t_c6 = FactoryGirl.create :tile_completion, tile: @t3, user: @gu3
    end

    it "should return only tile completions from current board for correct tile" do
      tc = TileCompletion.tile_completions_with_users @t1
      tc.should include(@t_c1, @t_c4)
      tc.should_not include(@t_c2, @t_c3, @t_c5, @t_c6)
    end
  end
end

