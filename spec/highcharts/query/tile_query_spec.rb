require "spec_helper"

describe Query::TileQuery do
  let!(:tile) { FactoryGirl.create :tile }

  context "Hourly interval" do
    let!(:period) { Period.new 'hourly', "Sep 18, 2015", "Sep 18, 2015" }

    before do
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
        FactoryGirl.create :tile_completion, tile: tile, created_at: created_at
      end
    end

    it "should return aggregated total tile viewings data" do
      Query::TotalViews.new(tile, period).query.should ==
        {
          "2015-09-18 00:00:00"=>3,
          "2015-09-18 10:00:00"=>5,
          "2015-09-18 15:00:00"=>1,
          "2015-09-18 23:00:00"=>10
        }
    end

    it "should return aggregated unique tile viewings data" do
      Query::UniqueViews.new(tile, period).query.should ==
        {
          "2015-09-18 00:00:00"=>1,
          "2015-09-18 10:00:00"=>1,
          "2015-09-18 15:00:00"=>1,
          "2015-09-18 23:00:00"=>2
        }
    end

    it "should return aggregated tile completions data" do
      Query::Interactions.new(tile, period).query.should ==
        {
          "2015-09-18 00:00:00"=>1,
          "2015-09-18 10:00:00"=>1,
          "2015-09-18 15:00:00"=>1,
          "2015-09-18 23:00:00"=>2
        }
    end
  end

  context "Daily interval" do
    let!(:period) { Period.new 'daily', "Sep 14, 2015", "Sep 18, 2015" } # american format

    before do
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
        FactoryGirl.create :tile_completion, tile: tile, created_at: created_at
      end
    end

    it "should return aggregated total tile viewings data" do
      Query::TotalViews.new(tile, period).query.should ==
        {
          "2015-09-14 00:00:00"=>3,
          "2015-09-15 00:00:00"=>5,
          "2015-09-16 00:00:00"=>1,
          "2015-09-18 00:00:00"=>10
        }
    end

    it "should return aggregated unqie tile viewings data" do
      Query::UniqueViews.new(tile, period).query.should ==
        {
          "2015-09-14 00:00:00"=>1,
          "2015-09-15 00:00:00"=>1,
          "2015-09-16 00:00:00"=>1,
          "2015-09-18 00:00:00"=>2
        }
    end

    it "should return aggregated tile completions data" do
      Query::Interactions.new(tile, period).query.should ==
        {
          "2015-09-14 00:00:00"=>1,
          "2015-09-15 00:00:00"=>1,
          "2015-09-16 00:00:00"=>1,
          "2015-09-18 00:00:00"=>2
        }
    end
  end

  context "Weekly interval" do
    let!(:period) { Period.new 'weekly', "Sep 13, 2015", "Sep 26, 2015" } # american format
    # It fetches data from Posgresql grouped by start of the week.
    # We use date_trunc('week', created_at) for it.
    # And start of the week is Monday in db.
    #
    # ncal -M september 2015
    #     September 2015
    # Mo     7 14 21 28
    # Tu  1  8 15 22 29
    # We  2  9 16 23 30
    # Th  3 10 17 24
    # Fr  4 11 18 25
    # Sa  5 12 19 26
    # Su  6 13 20 27
    before do
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
        FactoryGirl.create :tile_completion, tile: tile, created_at: created_at
      end
    end

    it "should return aggregated total tile viewings data" do
      Query::TotalViews.new(tile, period).query.should ==
        {
          "2015-09-07 00:00:00"=>3,
          "2015-09-14 00:00:00"=>8,
          "2015-09-21 00:00:00"=>8
        }
    end

    it "should return aggregated unique tile viewings data" do
      Query::UniqueViews.new(tile, period).query.should ==
        {
          "2015-09-07 00:00:00"=>1,
          "2015-09-14 00:00:00"=>3,
          "2015-09-21 00:00:00"=>1
        }
    end

    it "should return aggregated tile completions data" do
      Query::Interactions.new(tile, period).query.should ==
        {
          "2015-09-07 00:00:00"=>1,
          "2015-09-14 00:00:00"=>3,
          "2015-09-21 00:00:00"=>1
        }
    end
  end

  context "Montly interval" do
    let!(:period) { Period.new 'monthly', "Aug 14, 2015", "Oct 18, 2015" } # american format

    before do
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
        FactoryGirl.create :tile_completion, tile: tile, created_at: created_at
      end
    end

    it "should return aggregated total tile viewings data" do
      Query::TotalViews.new(tile, period).query.should ==
        {
          "2015-08-01 00:00:00"=>8,
          "2015-09-01 00:00:00"=>1,
          "2015-10-01 00:00:00"=>10
        }
    end

    it "should return aggregated unique tile viewings data" do
      Query::UniqueViews.new(tile, period).query.should ==
        {
          "2015-08-01 00:00:00"=>2,
          "2015-09-01 00:00:00"=>1,
          "2015-10-01 00:00:00"=>2
        }
    end

    it "should return aggregated tile ineractions data" do
      Query::Interactions.new(tile, period).query.should ==
        {
          "2015-08-01 00:00:00"=>2,
          "2015-09-01 00:00:00"=>1,
          "2015-10-01 00:00:00"=>2
        }
    end
  end
end
