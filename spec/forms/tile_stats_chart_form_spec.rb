require "spec_helper"

describe TileStatsChartForm do
  let(:tile) { FactoryGirl.create :tile }

  before do
    Timecop.travel(Chronic.parse("2015-08-24"))
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
      expect(form.action_type).to eq("unique_views")
      expect(form.interval_type).to eq("daily")
      expect(form.value_type).to eq("cumulative")
      expect(form.date_range_type).to eq("past_week")
      expect(form.start_date).to eq("Aug 17, 2015")
      expect(form.end_date).to eq("Aug 24, 2015")
    end
  end
end
