require 'reporting/db'
require 'spec_helper'
module Reporting
  module Db

    def setup_data

      @demo = FactoryGirl.create(:demo)
      @demo2 = FactoryGirl.create(:demo)


      @tile1 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)
      @tile2 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)
      @tile3 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 3.weeks.ago)

      @activated_before_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo,  created_at: 16.weeks.ago, activated_at: 16.weeks.ago)

      @posted_within_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 7.weeks.ago, activated_at: 7.weeks.ago)

      @archived_before_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo, activated_at: 20.weeks.ago, archived_at: 16.weeks.ago)
      @belongs_to_different_demo_tile = FactoryGirl.create(:tile, :active, demo: @demo2, created_at: 8.weeks.ago, activated_at: 3.weeks.ago)


     
      @user1 = FactoryGirl.create(:user, demo: @demo, name: "User 1", accepted_invitation_at: 10.weeks.ago)
      @user2 = FactoryGirl.create(:user, demo: @demo, name: "User 2", accepted_invitation_at: 10.weeks.ago)
      @user3 = FactoryGirl.create(:user, demo: @demo, name: "User 3", accepted_invitation_at: 10.weeks.ago)
      @user4 = FactoryGirl.create(:user, demo: @demo, name: "User 4", accepted_invitation_at: 10.weeks.ago)
      @user5 = FactoryGirl.create(:user, demo: @demo, name: "User 4", accepted_invitation_at: 5.weeks.ago)


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

    describe TileActivity do
      include Db

      before do
        setup_data
        @tar = TileActivity.new(@demo, 8.weeks.ago, Date.today, "week")
      end

      describe "posted" do
        it "counts only posted tiles for this demo" do 
          posted =@tar.posted 
          expect(posted.first.count).to eq "1"
        end
      end

      describe "available" do
        it "counts only posted tiles for this demo" do 
          available =@tar.available 
          expect(available.map(&:count)).to eq ["1", "3", "4", "5"]
        end
      end

      describe "tile_views" do
        it "counts only unique tile views" do 

          views =@tar.available 
          binding.pry
          expect(@tar.views).to eq 8
        end
      end

      describe "tile_completions" do
        it "counts only unique tile views" do 
          expect(@tar.completions).to eq 7
        end
      end

    end

    describe UserActivation do
      include Db

      before do
        setup_data
        @act = UserActivation.new(@demo, 8.weeks.ago, Date.today, "week")
      end

      describe "total_activated" do
        it "returns a count" do
          res = @act.total_activated
          expect(res.map(&:count)).to eq ["4","5"]
        end
      end
    end

    describe ClientUsage do
      include Db
      before do
        setup_data
      end
      it "returns {} when demo is nil" do 
        expect(ClientUsage.run(nil)[:demo_id]).to be_nil
      end

      it "returns data broken out by interval" do 
        res = ClientUsage.run(@demo.id)
        time_stamp1 = 10.weeks.ago.beginning_of_week.to_date
        time_stamp2 = 5.weeks.ago.beginning_of_week.to_date
        expect(res[time_stamp1][:activation][:newly_activated]).to eq("4")
        expect(res[time_stamp1][:activation][:activation_pct]).to eq(0.8)
        expect(res[time_stamp2][:activation][:newly_activated]).to eq("1")
        expect(res[time_stamp2][:activation][:activation_pct]).to eq(0.2)
      end

    end

  end
end



