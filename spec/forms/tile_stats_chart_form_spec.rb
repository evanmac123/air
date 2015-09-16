require "spec_helper"

describe TileStatsChartForm do
  let(:tile) { FactoryGirl.create :tile }

  before do
    Timecop.travel(Chronic.parse("2015-24-08"))
  end

  after do
    Timecop.return
  end

  context "#chart_params" do
    it "should return right params if date range is selected" do
      params = {
        :"action_type"=>"unique_views",
        :"interval_type"=>"weekly",
        :"value_type"=>"cumulative",
        :"date_range_type"=>"past_week",
        :"start_date"=>"Jan, 08 2015",
        :"end_date"=>"Aug, 24 2015",
        :"changed_field"=>"date_range_type"
      }
      form = TileStatsChartForm.new tile, params
      form.action_type.should == "unique_views"
      form.interval_type.should == "daily"
      form.value_type.should == "cumulative"
      form.date_range_type.should == "past_week"
      form.start_date.should == "Sep 09, 2015"
      form.end_date.should == "Sep 16, 2015"
    end
  end
end
