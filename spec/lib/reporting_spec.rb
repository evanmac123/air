require 'reporting/db'
require 'spec_helper'

describe Reporting::Db::TileActivity do

  before do
    @demo = FactoryGirl.create(:demo)
    @demo2 = FactoryGirl.create(:demo)

    @tar = Reporting::Db::TileActivity.new(@demo, 8.weeks.ago, Date.today)

    @tile1 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)
    @tile2 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)
    @tile3 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)

    @activated_before_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo,  activated_at: 16.weeks.ago)

    @posted_within_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 7.weeks.ago, activated_at: 7.weeks.ago)


    @archived_before_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo, activated_at: 20.weeks.ago, archived_at: 16.weeks.ago)

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

  end

  describe "tiles_posted" do
    it "counts only posted tiles for this demo" do 
      expect(@tar.posted).to eq 1
    end
  end

  describe "tiles_available" do
    it "counts only posted tiles for this demo" do 
      expect(@tar.available).to eq 5
    end
  end

  describe "tile_views" do
    it "counts only unique tile views" do 
      expect(@tar.views).to eq 8
    end
  end

  describe "tile_completions" do
    it "counts only unique tile views" do 
      expect(@tar.completions).to eq 7
    end
  end

end



