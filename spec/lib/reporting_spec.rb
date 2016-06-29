require 'reporting/db'
require 'spec_helper'

describe Reporting::Db::TileActivity do

  before do
    @demo = FactoryGirl.create(:demo)
    @demo2 = FactoryGirl.create(:demo)

    @tile1 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)
    @tile2 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)
    @tile3 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)


    
    @activated_before_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 20.weeks.ago, activated_at: 16.weeks.ago)
    @archived_before_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 20.weeks.ago, archived_at: 16.weeks.ago)

    @belongs_to_different_demo_tile = FactoryGirl.create(:tile, :active, demo: @demo2, created_at: 8.weeks.ago, activated_at: 3.weeks.ago)



    @user1 = FactoryGirl.create(:user, name: "User 1")
    @user2 = FactoryGirl.create(:user, name: "User 2")
    @user3 = FactoryGirl.create(:user, name: "User 3")
    @user4 = FactoryGirl.create(:user, name: "User 4")


    FactoryGirl.create(:tile_viewing, user: @user1, tile: @tile1, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_viewing, user: @user1, tile: @tile2, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_viewing, user: @user1, tile: @tile3, created_at: 2.weeks.ago)

    FactoryGirl.create(:tile_viewing, user: @user2, tile: @tile1, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_viewing, user: @user2, tile: @tile2, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_viewing, user: @user2, tile: @tile3, created_at: 2.weeks.ago)

    FactoryGirl.create(:tile_viewing, user: @user3, tile: @tile1, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_viewing, user: @user3, tile: @tile2, created_at: 2.weeks.ago)

    FactoryGirl.create(:tile_completion, user: @user1, tile: @tile1, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_completion, user: @user1, tile: @tile2, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_completion, user: @user1, tile: @tile3, created_at: 2.weeks.ago)

    FactoryGirl.create(:tile_completion, user: @user2, tile: @tile1, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_completion, user: @user2, tile: @tile2, created_at: 2.weeks.ago)

    FactoryGirl.create(:tile_completion, user: @user3, tile: @tile1, created_at: 2.weeks.ago)

    #Tiles was avaiable before reporting range
    FactoryGirl.create(:tile_completion, user: @user3, tile: @activated_before_reporting_range_tile, created_at: 2.weeks.ago)

    FactoryGirl.create(:tile_completion, user: @user4, tile: @belongs_to_different_demo_tile, created_at: 2.weeks.ago)
    FactoryGirl.create(:tile_completion, user: @user4, tile: @archived_before_reporting_range_tile, created_at: 18.weeks.ago)

    @tar = Reporting::Db::TileActivity.new(@demo, 8.weeks.ago, Date.today)
  end

  describe "tiles_posted_count" do
    it "counts only posted tiles for this demo" do 
      expect(@tar.tiles_posted_count).to eq 4
    end
  end

  describe "unique_tile_views_count" do
    it "counts only unique tile views" do 
      expect(@tar.unique_tile_views_count).to eq 8
    end
  end

  describe "unique_tile_completions_count" do
    it "counts only unique tile views" do 
      expect(@tar.unique_tile_conpletions_count).to eq 7
    end
  end

end



