require "spec_helper"

describe PlotData do
  context "period: hourly, action_query: total_views" do
    before do
      @period = Period.new 'hourly', "Sep 18, 2015", "Sep 18, 2015"
      # action_query
      tile = FactoryGirl.create :tile
      [
        [Time.new(2015, 9, 18, 0, 10, 0, "+00:00"), 3],
        [Time.new(2015, 9, 18, 10, 20, 0, "+00:00"), 5],
        [Time.new(2015, 9, 18, 15, 59, 0, "+00:00"), 1],
        [Time.new(2015, 9, 18, 23, 35, 0, "+00:00"), 2],
        [Time.new(2015, 9, 18, 23, 37, 0, "+00:00"), 8],
        # bad dates:
        [Time.new(2015, 9, 17, 23, 59, 0, "+00:00"), 2],
        [Time.new(2015, 9, 19, 0, 1, 0, "+00:00"), 8]
      ].each do |created_at, views|
        FactoryGirl.create :tile_viewing, tile: tile, views: views, created_at: created_at
      end
      @action_query = Query::TotalViews.new(tile, @period)
      # @action_query.query result:
      # {"2015-09-18 00:00:00"=>3, "2015-09-18 10:00:00"=>5, "2015-09-18 15:00:00"=>1,"2015-09-18 23:00:00"=>10}
    end

    it "should fill actions for value_type: activity" do
      @value_type = "activity"
      plot_data = PlotData.new @period, @action_query, @value_type
      plot_data.send(:data_hash).should ==
        {
          "2015-09-18 00:00:00"=>3, "2015-09-18 01:00:00"=>0, "2015-09-18 02:00:00"=>0, "2015-09-18 03:00:00"=>0,
          "2015-09-18 04:00:00"=>0, "2015-09-18 05:00:00"=>0, "2015-09-18 06:00:00"=>0, "2015-09-18 07:00:00"=>0,
          "2015-09-18 08:00:00"=>0, "2015-09-18 09:00:00"=>0, "2015-09-18 10:00:00"=>5, "2015-09-18 11:00:00"=>0,
          "2015-09-18 12:00:00"=>0, "2015-09-18 13:00:00"=>0, "2015-09-18 14:00:00"=>0, "2015-09-18 15:00:00"=>1,
          "2015-09-18 16:00:00"=>0, "2015-09-18 17:00:00"=>0, "2015-09-18 18:00:00"=>0, "2015-09-18 19:00:00"=>0,
          "2015-09-18 20:00:00"=>0, "2015-09-18 21:00:00"=>0, "2015-09-18 22:00:00"=>0, "2015-09-18 23:00:00"=>10
        }
      plot_data.data.should == [3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 10]
    end

    it "should fill actions for value_type: cumulative" do
      @value_type = "cumulative"
      plot_data = PlotData.new @period, @action_query, @value_type
      plot_data.data.should == [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 19]
    end
  end

  context "period: daily, action_query: total_views" do
    before do
      @period = Period.new 'daily', "Sep 14, 2015", "Sep 18, 2015"
      # action_query
      tile = FactoryGirl.create :tile
      [
        [Time.new(2015, 9, 14, 0, 10, 0, "+00:00"), 3],
        [Time.new(2015, 9, 15, 10, 20, 0, "+00:00"), 5],
        [Time.new(2015, 9, 16, 15, 59, 0, "+00:00"), 1],
        [Time.new(2015, 9, 18, 23, 35, 0, "+00:00"), 2],
        [Time.new(2015, 9, 18, 23, 37, 0, "+00:00"), 8],
        # bad dates:
        [Time.new(2015, 9, 13, 23, 59, 0, "+00:00"), 2],
        [Time.new(2015, 9, 19, 0, 1, 0, "+00:00"), 8]
      ].each do |created_at, views|
        FactoryGirl.create :tile_viewing, tile: tile, views: views, created_at: created_at
      end
      @action_query = Query::TotalViews.new(tile, @period)
      # @action_query.query result:
      # {"2015-09-14 00:00:00"=>3, "2015-09-15 00:00:00"=>5, "2015-09-16 00:00:00"=>1, "2015-09-18 00:00:00"=>10}
    end

    it "should fill actions for value_type: activity" do
      @value_type = "activity"
      plot_data = PlotData.new @period, @action_query, @value_type
      plot_data.send(:data_hash).should ==
        {
          "2015-09-14 00:00:00"=>3,
          "2015-09-15 00:00:00"=>5,
          "2015-09-16 00:00:00"=>1,
          "2015-09-17 00:00:00"=>0,
          "2015-09-18 00:00:00"=>10
        }
      plot_data.data.should == [3, 5, 1, 0, 10]
    end

    it "should fill actions for value_type: cumulative" do
      @value_type = "cumulative"
      plot_data = PlotData.new @period, @action_query, @value_type
      plot_data.data.should == [3, 8, 9, 9, 19]
    end
  end

  context "period: weekly, action_query: total_views" do
    before do
      @period = Period.new 'weekly', "Sep 13, 2015", "Sep 26, 2015"
      # action_query
      tile = FactoryGirl.create :tile
      [
        [Time.new(2015, 9, 13, 0, 10, 0, "+00:00"), 3],
        [Time.new(2015, 9, 14, 10, 20, 0, "+00:00"), 5],
        [Time.new(2015, 9, 17, 15, 59, 0, "+00:00"), 1],
        [Time.new(2015, 9, 20, 23, 35, 0, "+00:00"), 2],
        [Time.new(2015, 9, 26, 23, 37, 0, "+00:00"), 8],
        # bad dates:
        [Time.new(2015, 9, 12, 23, 59, 0, "+00:00"), 2],
        [Time.new(2015, 9, 27, 23, 59, 0, "+00:00"), 2],
        [Time.new(2015, 9, 28, 0, 1, 0, "+00:00"), 8]
      ].each do |created_at, views|
        FactoryGirl.create :tile_viewing, tile: tile, views: views, created_at: created_at
      end
      @action_query = Query::TotalViews.new(tile, @period)
      # @action_query.query result:
      # {"2015-09-07 00:00:00"=>3, "2015-09-14 00:00:00"=>8, "2015-09-21 00:00:00"=>8 }
    end

    it "should fill actions for value_type: activity" do
      @value_type = "activity"
      plot_data = PlotData.new @period, @action_query, @value_type
      plot_data.send(:data_hash).should ==
        {
          "2015-09-07 00:00:00"=>3,
          "2015-09-14 00:00:00"=>8,
          "2015-09-21 00:00:00"=>8
        }
      plot_data.data.should == [3, 8, 8]
    end

    it "should fill actions for value_type: cumulative" do
      @value_type = "cumulative"
      plot_data = PlotData.new @period, @action_query, @value_type
      plot_data.data.should == [3, 11, 19]
    end
  end

  context "period: monthly, action_query: total_views" do
    before do
      @period = Period.new 'monthly', "Aug 14, 2015", "Oct 18, 2015"
      # action_query
      tile = FactoryGirl.create :tile
      [
        [Time.new(2015, 8, 14, 0, 10, 0, "+00:00"), 3],
        [Time.new(2015, 8, 15, 10, 20, 0, "+00:00"), 5],
        [Time.new(2015, 9, 16, 15, 59, 0, "+00:00"), 1],
        [Time.new(2015, 10, 1, 23, 35, 0, "+00:00"), 2],
        [Time.new(2015, 10, 18, 23, 37, 0, "+00:00"), 8],
        # bad dates:
        [Time.new(2015, 8, 13, 23, 59, 0, "+00:00"), 2],
        [Time.new(2015, 10, 19, 0, 1, 0, "+00:00"), 8]
      ].each do |created_at, views|
        FactoryGirl.create :tile_viewing, tile: tile, views: views, created_at: created_at
      end
      @action_query = Query::TotalViews.new(tile, @period)
      # @action_query.query result:
      # { "2015-08-01 00:00:00"=>8, "2015-09-01 00:00:00"=>1, "2015-10-01 00:00:00"=>10 }
    end

    it "should fill actions for value_type: activity" do
      @value_type = "activity"
      plot_data = PlotData.new @period, @action_query, @value_type
      plot_data.send(:data_hash).should ==
      {
        "2015-08-01 00:00:00"=>8,
        "2015-09-01 00:00:00"=>1,
        "2015-10-01 00:00:00"=>10
      }
      plot_data.data.should == [8, 1, 10]
    end

    it "should fill actions for value_type: cumulative" do
      @value_type = "cumulative"
      plot_data = PlotData.new @period, @action_query, @value_type
      plot_data.data.should == [8, 9, 19]
    end
  end
end
