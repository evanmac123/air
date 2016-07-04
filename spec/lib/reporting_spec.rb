require 'reporting/db'
require 'spec_helper'
module Reporting
  module Db

    def setup_data

      @demo = FactoryGirl.create(:demo)
      @demo2 = FactoryGirl.create(:demo)


      @activated_before_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo,  created_at: 16.weeks.ago, activated_at: 16.weeks.ago)

      @tile1 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)
      @tile2 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 11.weeks.ago)
      @tile3 = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 12.weeks.ago, activated_at: 3.weeks.ago)

      @posted_within_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo, created_at: 7.weeks.ago, activated_at: 7.weeks.ago)

      @archived_before_reporting_range_tile = FactoryGirl.create(:tile, :active, demo: @demo, activated_at: 20.weeks.ago, archived_at: 16.weeks.ago)
      @belongs_to_different_demo_tile = FactoryGirl.create(:tile, :active, demo: @demo2, created_at: 8.weeks.ago, activated_at: 3.weeks.ago)


     
      @user1 = FactoryGirl.create(:user, demo: @demo, name: "User 1", accepted_invitation_at: 10.weeks.ago)
      @user2 = FactoryGirl.create(:user, demo: @demo, name: "User 2", accepted_invitation_at: 10.weeks.ago)
      @user3 = FactoryGirl.create(:user, demo: @demo, name: "User 3", accepted_invitation_at: 10.weeks.ago)
      @user4 = FactoryGirl.create(:user, demo: @demo, name: "User 4", accepted_invitation_at: 10.weeks.ago)
      @user5 = FactoryGirl.create(:user, demo: @demo, name: "User 5", accepted_invitation_at: 5.weeks.ago)

      FactoryGirl.create(:tile_viewing, user: @user4, tile: @activated_before_reporting_range_tile, created_at: 13.weeks.ago)
      FactoryGirl.create(:tile_viewing, user: @user5, tile: @activated_before_reporting_range_tile, created_at: 13.weeks.ago)

      FactoryGirl.create(:tile_viewing, user: @user1, tile: @tile1, created_at: 5.weeks.ago)
      FactoryGirl.create(:tile_viewing, user: @user1, tile: @tile2, created_at: 5.weeks.ago)
      FactoryGirl.create(:tile_viewing, user: @user1, tile: @tile3, created_at: 5.weeks.ago)

      FactoryGirl.create(:tile_viewing, user: @user2, tile: @tile1, created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_viewing, user: @user2, tile: @tile2, created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_viewing, user: @user2, tile: @tile3, created_at: 2.weeks.ago)

      FactoryGirl.create(:tile_viewing, user: @user3, tile: @tile1, created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_viewing, user: @user3, tile: @tile2, created_at: 2.weeks.ago)




      #----COMPLETIONS------
      FactoryGirl.create(:tile_completion, user: @user1, tile: @tile1, created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user1, tile: @tile2, created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user1, tile: @tile3, created_at: 2.weeks.ago)

      FactoryGirl.create(:tile_completion, user: @user2, tile: @tile1, created_at: 5.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user2, tile: @tile2, created_at: 5.weeks.ago)

      FactoryGirl.create(:tile_completion, user: @user3, tile: @tile1, created_at: 8.weeks.ago)

      FactoryGirl.create(:tile_completion, user: @user3, tile: @activated_before_reporting_range_tile, created_at: 11.weeks.ago)

      FactoryGirl.create(:tile_completion, user: @user4, tile: @belongs_to_different_demo_tile, created_at: 2.weeks.ago)
      FactoryGirl.create(:tile_completion, user: @user4, tile: @archived_before_reporting_range_tile, created_at: 18.weeks.ago)
    end

    describe TileActivity do
      include Db

      before do
        setup_data
        @tar = TileActivity.new(@demo, 8.weeks.ago, Date.today, "week")
      end

      describe "available" do
        it "does cumulative count of tiles activated for this demo" do 
          available =@tar.available 
          expect(available.map(&:cumulative_count)).to eq ["1", "3", "4", "5"]
          expect(available.map(&:interval_count)).to eq ["1", "2", "1", "1"]
        end
      end

      describe "tile_views" do
        it "counts only unique tile views" do 
          views =@tar.views 
          expect(views.map(&:cumulative_count)).to eq [ "3", "8"]
          expect(views.map(&:interval_count)).to eq ["3", "5"]
        end
      end

      describe "tile_completions" do
        it "counts only unique tile views" do 
          completions =@tar.completions 
          expect(completions.map(&:cumulative_count)).to eq [ "1", "3", "6"]
          expect(completions.map(&:interval_count)).to eq ["1", "2", "3"]
        end
      end

    end

    describe UserActivation do
      include Db

      before do
        setup_data
        @act = UserActivation.new(@demo, 8.weeks.ago, Date.today, "week")
      end

      describe "activated" do
        it "returns a count" do
          activations = @act.activated
          expect(activations.map(&:cumulative_count)).to eq ["4","5"]
          expect(activations.map(&:interval_count)).to eq ["4","1"]
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
        expect(res[time_stamp2][:activation][:activation_pct]).to eq(1.0)
      end

    end

  end
end



