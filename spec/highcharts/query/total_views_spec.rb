require "spec_helper"

describe Query::TotalViews do
  let!(:tile) { FactoryGirl.create :tile }

  context "Hourly interval" do
    let!(:period) { Period.new 'hourly', "9/18/2015", "9/18/2015" } # american format
    # +4000 time zone
    before do
      [
        [Time.new(2015, 9, 18, 0, 10), 3],
        [Time.new(2015, 9, 18, 10, 20), 5],
        [Time.new(2015, 9, 18, 15, 59, 0), 1],
        [Time.new(2015, 9, 18, 23, 35, 0), 2],
        [Time.new(2015, 9, 18, 23, 37, 0), 8]
      ].each do |created_at, views|
        FactoryGirl.create :tile_viewing, tile: tile, views: views, created_at: created_at
      end
    end

    it "should return aggregated tile viewings data" do
      Query::TotalViews.new(tile, period).query.should ==
        {"2015-09-18 14:00:00"=>5, "2015-09-18 04:00:00"=>3, "2015-09-18 19:00:00"=>1, "2015-09-19 03:00:00"=>10}
    end
  end
end
