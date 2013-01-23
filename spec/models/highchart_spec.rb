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
# The methods that made sense to unit test, are. The ones that just play a simple role in the overall determination
# of the acts-per-point are tested as a part of the the final 'data_points' method (in the Chart base class)

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
  let(:demo) { FactoryGirl.create :demo }

  context 'Hourly Points' do
    let(:start_date) { '12/25/2012' }
    let(:end_date)   { '12/25/2012' }

    let(:start_boundary) { Highchart.convert_date(start_date).beginning_of_day }
    let(:end_boundary)   { Highchart.convert_date(end_date).end_of_day }

    before(:each) do
      # Create some acts that lie outside the input range
      (1..2).each do |i|
        FactoryGirl.create :act, demo: demo, created_at: start_boundary - i.minutes
        FactoryGirl.create :act, demo: demo, created_at: end_boundary + i.minutes
      end

      # Create some acts that span the boundary day by minutes and also some that land squarely within the range
      in_range_acts = []
      (1..2).each do |i|
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: start_boundary + i.minutes)
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: end_boundary - i.minutes)

        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: start_boundary + i.hours)
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: end_boundary - i.hours)
      end

      @sorted_ids = in_range_acts.collect(&:id).sort  # What tests will compare against
    end

    describe Highchart::Hourly do
      let(:hourly) { Highchart::Hourly.new(demo, start_date, end_date, nil, nil) }
      let(:acts)   { hourly.get_all_acts_between_start_and_end_dates }

      describe '#get_all_acts_between_start_and_end_dates' do
        it 'should fetch the appropriate acts' do
          acts.collect(&:id).sort.should == @sorted_ids

          acts.count.should == 8
          demo.acts.count.should == 12  # Make sure the bad acts were created
        end
      end

      describe '#group_acts_per_time_interval' do
        it 'should group the right acts in the right days' do
          grouped_acts = hourly.group_acts_per_time_interval(acts)

          grouped_acts.each { |group| p group.inspect }

          # todo convert 'time' to ??? so don't have to worry about todo's below
          # For each of the hours that should contain acts...
          [start_boundary, start_boundary + 1.hour, start_boundary + 2.hours,
           end_boundary,   end_boundary - 1.hour,   end_boundary - 2.hours].each do |time|

            # Make sure this hour contains the correct number of acts
            # (Boundary hour got acts for +/- 1- and 2-minutes, while inner hours got just one act per hour)
            grouped_acts[(time.hour + 5.hours) % 24].should have((time == start_boundary or time == end_boundary) ? 2 : 1).acts

            # Make sure each act belongs in this hour
            # todo Phil: Perfect example:
            # todo 1st time must b 5.hours or else get "undefined method `each' for nil:NilClass"
            # todo 2nd time must just 5 or else get "expected 0, got 19 mismatch"
            grouped_acts[(time.hour + 5.hours) % 24].each { |act| ((act.created_at.hour + 5) % 24).should == time.hour }
          end

          # And finally, make sure no other hours snuck into the grouping hash
          grouped_acts.keys.count.should == 6
        end
      end
    end
  end

  context 'Daily Points' do
    # Pick days that not only straddle a month, but a year as well
    let(:start_date) { '12/25/2012' }
    let(:end_date)   { '01/16/2013' }

    let(:start_boundary) { Highchart.convert_date(start_date).beginning_of_day }
    let(:end_boundary)   { Highchart.convert_date(end_date).end_of_day }

    before(:each) do
      # Create some acts that lie outside the input range
      (1..2).each do |i|
        FactoryGirl.create :act, demo: demo, created_at: start_boundary - i.minutes
        FactoryGirl.create :act, demo: demo, created_at: end_boundary + i.minutes
      end

      # Create some acts that span the boundary days by minutes and also some that land squarely within the range
      in_range_acts = []
      (1..2).each do |i|
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: start_boundary + i.minutes)
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: end_boundary - i.minutes)
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: start_boundary + i.days)
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: end_boundary - i.days)
      end

      @sorted_ids = in_range_acts.collect(&:id).sort  # What tests will compare against
    end

    describe Highchart::Daily do
      let(:daily) { Highchart::Daily.new(demo, start_date, end_date, nil, nil) }
      let(:acts)  { daily.get_all_acts_between_start_and_end_dates }

      describe '#get_all_acts_between_start_and_end_dates' do
        it 'should fetch the appropriate acts' do
          acts.collect(&:id).sort.should == @sorted_ids

          acts.count.should == 8
          demo.acts.count.should == 12  # Make sure the bad acts were created
        end
      end

      describe '#group_acts_per_time_interval' do
        it 'should group the right acts in the right days' do
          grouped_acts = daily.group_acts_per_time_interval(acts)

          # For each of the days that should contain acts...
          [start_boundary, start_boundary + 1.day, start_boundary + 2.days,
           end_boundary,   end_boundary - 1.day,   end_boundary - 2.days].each do |day|
            # Make sure this day contains the correct number of acts
            # (Boundary days got acts for +/- 1- and 2-minutes, while inner days got just one act per day)
            grouped_acts[day.to_date].should have((day == start_boundary or day == end_boundary) ? 2 : 1).acts

            # Make sure each act belongs in this day
            # (Had to add 5.hours to each act to get it into the right group => do the same thing here)
            grouped_acts[day.to_date].each { |act| (act.created_at + 5.hours).to_date.should == day.to_date }
          end

          # And finally, make sure no other days snuck into the grouping hash
          grouped_acts.keys.count.should == 6
        end
      end
    end

    # The weekly plot gets a little confusing, so here's a visual representation of what we are dealing with.
    # Remember, the range is Dec. 25 thru Jan 16. These days were picked to not only straddle both a month
    # and a year, but to test the weekly view's "problem end points."
    #
    # Specifically, the plot points and ranges are:
    # Week 1: Dec 25 thru Dec 31 ; Dec 25 should contain 4 acts (25 - 2, 26 - 1, 27 - 1)
    # Week 2: Jan 1 thru Jan 7   ; Jan 1 should contain 0 acts
    # Week 3: Jan 8 thru Jan 14  ; Jan 8 should contain 1 act (14 - 1)
    # Week 4: Jan 15 thru Jan 16 ; Jan 15 should contain 3 acts (15 - 1, 16 - 2)
    #
    # This ensures that we test a last plotted-point (Jan 15) occurring before the end date of the range
=begin
        DECEMBER 2012
Su	Mo	Tu	We	Th	Fr	Sa
23	24	25	26	27	28	29
30	31  1   2   3   4   5
        JANUARY 2013
Su	Mo	Tu	We	Th	Fr	Sa
30  31  1	  2	  3	  4	  5
6	  7	  8	  9	  10	11	12
13	14	15	16	17	18	19
=end

    describe Highchart::Weekly do
      let(:weekly) { Highchart::Weekly.new(demo, start_date, end_date, nil, nil) }
      let(:acts)   { weekly.get_all_acts_between_start_and_end_dates }

      describe '#get_all_acts_between_start_and_end_dates' do
        it 'should fetch the appropriate acts' do
          acts.collect(&:id).sort.should == @sorted_ids

          acts.count.should == 8
          demo.acts.count.should == 12  # Make sure the bad acts were created
        end
      end

      describe '#group_acts_per_time_interval' do
        it 'should group the right acts in the right weeks' do
          num_acts = {}
          num_acts[start_boundary] = 4
          num_acts[start_boundary + 14.days] = 1
          num_acts[start_boundary + 21.days] = 3

          grouped_acts = weekly.group_acts_per_time_interval(acts)

            # For each of the weeks that should contain acts...
          [start_boundary, start_boundary + 14.days, start_boundary + 21.days].each do |day|
            # Make sure this week contains the correct number of acts
            grouped_acts[day.to_date].should have(num_acts[day]).acts

            # Make sure each act belongs in this week
            # (Had to add 5.hours to each act to get it into the right group => do the same thing here)
            grouped_acts[day.to_date].each { |act| (act.created_at + 5.hours).to_date.should < day + 7.days }
          end

          # And finally, make sure no other weeks snuck into the grouping hash
          grouped_acts.keys.count.should == 3
        end
      end
    end
  end
end
