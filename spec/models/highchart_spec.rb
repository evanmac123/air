require 'spec_helper'

# The only method tested in the 'Highchart' class is the 'convert_date' helper.
#
# Since the 'chart' method returns a 'LazyHighCharts::HighChart' object it is tested
# in spec/acceptance where we can verify what is actually contained in the chart.


# The 'Chart' class has 3 flavors of subclasses corresponding to the type of charts we can draw: Hourly, Daily, Weekly.
#
# Plot-output methods such as 'subtitle' and 'x-axis' are tested in spec/acceptance
# where we can verify what is actually contained in the chart.
#
# Other methods such as 'initialize_all_data_points_to_zero' and 'group_acts_per_time_interval' work together
# to produce the correct points for the desired plot. Instead of testing them individually the final 'data_points'
# method (in the Chart base class) is tested to make sure the correct points are returned for each type of chart.
#
# What does make sense to test, however, is the 'get_all_acts_between_start_and_end_dates' for each 'Chart' child
# class so we can make sure we handle the stupid %$#@!*&! EST vs. UTC timestamps in order to grab the correct acts.

describe Highchart do

  describe '#convert_date' do
    it "should convert a 'day/month/year' string to a 'month/day/year' DateTime" do
      Highchart.convert_date('12/24/2012').should == '24/12/2012'.to_datetime
      Highchart.convert_date('01/02/2012').should == '02/01/2012'.to_datetime
      Highchart.convert_date('7/4/12').should     == '4/7/12'.to_datetime
      Highchart.convert_date('11/6/2012').should  == '6/11/2012'.to_datetime
    end
  end

end

describe Highchart::Chart do

  describe '#data_points' do

  end
end

describe 'Chart Types' do

  before(:each) do
    @demo = FactoryGirl.create :demo

    @start_date = '01/04/2013'
    @end_date   = '01/24/2013'

    start_boundary = Highchart.convert_date(@start_date).beginning_of_day
    end_boundary   = Highchart.convert_date(@end_date).end_of_day

    # Create some acts that lie outside the input range
    (1..2).each do |i|
      FactoryGirl.create :act, demo: @demo, created_at: start_boundary - i.minutes
      FactoryGirl.create :act, demo: @demo, created_at: end_boundary + i.minutes
    end

    in_range_acts = []
    (1..2).each do |i|
      in_range_acts << FactoryGirl.create(:act, demo: @demo, created_at: start_boundary + i.minutes)
      in_range_acts << FactoryGirl.create(:act, demo: @demo, created_at: end_boundary - i.minutes)
    end
    @sorted_ids = in_range_acts.collect(&:id).sort
  end

  describe Highchart::Hourly do
    describe '#get_all_acts_between_start_and_end_dates' do

    end
  end

  describe Highchart::Daily do
    describe '#get_all_acts_between_start_and_end_dates' do
      it 'should fetch the correct acts' do
        in_range_acts = Highchart::Daily.new(@demo, @start_date, @end_date, nil, nil).get_all_acts_between_start_and_end_dates
        in_range_acts.collect(&:id).sort.should == @sorted_ids

        in_range_acts.count.should == 4
        @demo.acts.count.should == 8  # Make sure the bad acts were created
      end
    end
  end

  describe Highchart::Weekly do
    describe '#get_all_acts_between_start_and_end_dates' do

    end
  end
end
