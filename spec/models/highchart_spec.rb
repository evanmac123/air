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
      Highchart.convert_date('7/4/2012').should   == '4/7/2012'.to_datetime
      Highchart.convert_date('11/6/2012').should  == '6/11/2012'.to_datetime
    end
  end

end

describe 'Chart Types' do
  let(:demo) { FactoryGirl.create :demo }

  let(:john)   { FactoryGirl.create :user, demo: demo }
  let(:paul)   { FactoryGirl.create :user, demo: demo }
  let(:george) { FactoryGirl.create :user, demo: demo }
  let(:ringo)  { FactoryGirl.create :user, demo: demo }

  let(:acts_hash) { {} }

  # ---------------------------------------------------

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

        FactoryGirl.create(:act, demo: demo, created_at: start_boundary - i.hours)
        FactoryGirl.create(:act, demo: demo, created_at: end_boundary + i.hours)
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
          demo.acts.count.should == 16  # Make sure the bad acts were created
        end
      end

      describe '#group_acts_per_time_interval' do
        it 'should group the right acts in the right days' do
          grouped_acts = hourly.group_acts_per_time_interval(acts)

          # For each of the hours that should contain acts...
          [start_boundary, start_boundary + 1.hour, start_boundary + 2.hours,
           end_boundary,   end_boundary - 1.hour,   end_boundary - 2.hours].each do |time|

            # Make sure this hour contains the correct number of acts
            # (Boundary hour got acts for +/- 1- and 2-minutes, while inner hours got just one act per hour)
            grouped_acts[time.hour % 24].should have((time == start_boundary or time == end_boundary) ? 2 : 1).acts

            # Make sure each act belongs in this hour
            # (Had to add 5.hours to each act to get it into the right group => do the same thing here)
            grouped_acts[time.hour % 24].each { |act| ((act.created_at + 5.hours).hour % 24).should == time.hour }
          end

          # And finally, make sure no other hours snuck into the grouping hash
          grouped_acts.keys.count.should == 6
        end
      end

      describe '#calculate_number_per_time_interval' do
        it 'should report the correct number of acts and unique users for each interval' do

          # Interestingly enough, the Daily and Weekly tests that use dates in July (i.e. Daylight Savings Time
          # which results in an ActiveRecord offset of 4 hours in database records) pass.
          #
          # However, if you use a July date in this Hourly test it returns results that are off by 1 hour
          # because we adjust for the EST/UTC time difference by adding 5 hours to our act objects.
          # Bottom Line: Use a date that is not in Daylight Savings Time (March 11 thru November 4 for 2012)

          day = Highchart.convert_date('11/11/2012')
          hour_1  = day + 1.hour
          hour_2  = day + 2.hours
          hour_3  = day + 3.hours
          hour_21 = day + 21.hours
          hour_22 = day + 22.hours
          hour_23 = day + 23.hours

          # All 4 create multiple -----------------------------------------
          hour_1_john_3   = FactoryGirl.create_list :act, 3, demo: demo, created_at: hour_1, user: john
          hour_1_paul_2   = FactoryGirl.create_list :act, 2, demo: demo, created_at: hour_1, user: paul
          hour_1_george_5 = FactoryGirl.create_list :act, 5, demo: demo, created_at: hour_1, user: george
          hour_1_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_1, user: ringo

          acts_hash[hour_1] = hour_1_john_3 + hour_1_paul_2 + hour_1_george_5 + hour_1_ringo_1

          # All 4 create one each -----------------------------------------
          hour_2_john_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_2, user: john
          hour_2_paul_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_2, user: paul
          hour_2_george_1 = FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_2, user: george
          hour_2_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_2, user: ringo

          acts_hash[hour_2] = hour_2_john_1 + hour_2_paul_1 + hour_2_george_1 + hour_2_ringo_1

          # Nothing for hour_3 ----------------------------------------------

          # 1 creates multiple and 1 creates 1 -------------------------------
          hour_21_john_5   = FactoryGirl.create_list :act, 5, demo: demo, created_at: hour_21, user: john
          hour_21_paul_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_21, user: paul

          acts_hash[hour_21] = hour_21_john_5 + hour_21_paul_1

          # 1 creates multiple -------------------------------
          hour_22_george_3 = FactoryGirl.create_list :act, 3, demo: demo, created_at: hour_22, user: george

          acts_hash[hour_22] = hour_22_george_3

          # 1 creates 1 -------------------------------
          hour_23_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: hour_23, user: ringo

          acts_hash[hour_23] = hour_23_ringo_1

          hourly = Highchart::Hourly.new(demo, '11/11/2012', '11/11/2012', true, true)
          a_points, u_points = hourly.data_points

          p "******* #{a_points.inspect}"
          p "******* #{u_points.inspect}"

          # Calculations -------------------------------------
          hourly.calculate_number_per_time_interval(acts_hash)

          # Read 'em and weep (Hopefully) -------------------
          hourly.num_acts_per_interval[hour_1].should == 11
          hourly.num_users_per_interval[hour_1].should == 4

          hourly.num_acts_per_interval[hour_2].should == 4
          hourly.num_users_per_interval[hour_2].should == 4

          hourly.num_acts_per_interval[hour_3].should be_nil
          hourly.num_users_per_interval[hour_3].should be_nil

          hourly.num_acts_per_interval[hour_21].should == 6
          hourly.num_users_per_interval[hour_21].should == 2

          hourly.num_acts_per_interval[hour_22].should == 3
          hourly.num_users_per_interval[hour_22].should == 1

          hourly.num_acts_per_interval[hour_23].should == 1
          hourly.num_users_per_interval[hour_23].should == 1
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

        FactoryGirl.create(:act, demo: demo, created_at: start_boundary - i.hours)
        FactoryGirl.create(:act, demo: demo, created_at: end_boundary + i.hours)
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
          demo.acts.count.should == 16  # Make sure the bad acts were created
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

      describe '#calculate_number_per_time_interval' do
        it 'should report the correct number of acts and unique users for each interval' do
          day_1 = Highchart.convert_date('7/1/2012')
          day_2 = Highchart.convert_date('7/4/2012')
          day_3 = Highchart.convert_date('7/11/2012')
          day_4 = Highchart.convert_date('7/19/2012')
          day_5 = Highchart.convert_date('7/21/2012')
          day_6 = Highchart.convert_date('7/31/2012')

          # All 4 create multiple -----------------------------------------
          day_1_john_3   = FactoryGirl.create_list :act, 3, demo: demo, created_at: day_1, user: john
          day_1_paul_2   = FactoryGirl.create_list :act, 2, demo: demo, created_at: day_1, user: paul
          day_1_george_5 = FactoryGirl.create_list :act, 5, demo: demo, created_at: day_1, user: george
          day_1_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_1, user: ringo

          acts_hash[day_1] = day_1_john_3 + day_1_paul_2 + day_1_george_5 + day_1_ringo_1

          # All 4 create one each -----------------------------------------
          day_2_john_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_2, user: john
          day_2_paul_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_2, user: paul
          day_2_george_1 = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_2, user: george
          day_2_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_2, user: ringo

          acts_hash[day_2] = day_2_john_1 + day_2_paul_1 + day_2_george_1 + day_2_ringo_1

          # Nothing for day_3 ----------------------------------------------

          # 1 creates multiple and 1 creates 1 -------------------------------
          day_4_john_5   = FactoryGirl.create_list :act, 5, demo: demo, created_at: day_4, user: john
          day_4_paul_1   = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_4, user: paul

          acts_hash[day_4] = day_4_john_5 + day_4_paul_1

          # 1 creates multiple -------------------------------
          day_5_george_3 = FactoryGirl.create_list :act, 3, demo: demo, created_at: day_5, user: george

          acts_hash[day_5] = day_5_george_3

          # 1 creates 1 -------------------------------
          day_6_ringo_1  = FactoryGirl.create_list :act, 1, demo: demo, created_at: day_6, user: ringo

          acts_hash[day_6] = day_6_ringo_1

          daily = Highchart::Daily.new(demo, '7/1/2012', '7/31/2012', true, true)
          a_points, u_points = daily.data_points

          # Calculations -------------------------------------
          daily.calculate_number_per_time_interval(acts_hash)

          # Read 'em and weep (Hopefully) -------------------
          daily.num_acts_per_interval[day_1].should == 11
          daily.num_users_per_interval[day_1].should == 4

          daily.num_acts_per_interval[day_2].should == 4
          daily.num_users_per_interval[day_2].should == 4

          daily.num_acts_per_interval[day_3].should be_nil
          daily.num_users_per_interval[day_3].should be_nil

          daily.num_acts_per_interval[day_4].should == 6
          daily.num_users_per_interval[day_4].should == 2

          daily.num_acts_per_interval[day_5].should == 3
          daily.num_users_per_interval[day_5].should == 1

          daily.num_acts_per_interval[day_6].should == 1
          daily.num_users_per_interval[day_6].should == 1
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
    # This ensures that we test a last-plotted-point (Jan 15) occurring before the end date of the range
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
          demo.acts.count.should == 16  # Make sure the bad acts were created
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

      describe '#calculate_number_per_time_interval' do
        it 'should report the correct number of acts and unique users for each interval' do
          week_1 = Highchart.convert_date('7/21/2012')
          week_2 = week_1 + 7.days  # 7/28/2012
          week_3 = week_2 + 7.days  # 8/4/2012
          week_4 = week_3 + 7.days  # 8/11/2012
          week_5 = week_4 + 7.days  # 8/18/2012
          week_6 = week_5 + 7.days  # 8/25/2012

          # All 4 create multiple -----------------------------------------
          week_1_john_3_x_7   = []
          0.upto(6) { |i| week_1_john_3_x_7 << FactoryGirl.create_list(:act, 3, demo: demo, created_at: week_1 + i.days, user: john)   }
          week_1_john_3_x_7.flatten!

          week_1_paul_2_x_7   = []
          0.upto(6) { |i| week_1_paul_2_x_7 << FactoryGirl.create_list(:act, 2, demo: demo, created_at: week_1 + i.days, user: paul)   }
          week_1_paul_2_x_7.flatten!

          week_1_george_5_x_7 = []
          0.upto(6) { |i| week_1_george_5_x_7 << FactoryGirl.create_list(:act, 5, demo: demo, created_at: week_1 + i.days, user: george) }
          week_1_george_5_x_7.flatten!

          week_1_ringo_1_x_7  = []
          0.upto(6) { |i| week_1_ringo_1_x_7 << FactoryGirl.create_list(:act, 1, demo: demo, created_at: week_1 + i.days, user: ringo)  }
          week_1_ringo_1_x_7.flatten!

          acts_hash[week_1] = week_1_john_3_x_7 + week_1_paul_2_x_7 + week_1_george_5_x_7 + week_1_ringo_1_x_7

          # All 4 create one each -----------------------------------------
          week_2_john_1_x_7   = []
          0.upto(6) { |i| week_2_john_1_x_7 << FactoryGirl.create_list(:act, 1, demo: demo, created_at: week_2 + i.days, user: john)   }
          week_2_john_1_x_7.flatten!

          week_2_paul_1_x_7   = []
          0.upto(6) { |i| week_2_paul_1_x_7 << FactoryGirl.create_list(:act, 1, demo: demo, created_at: week_2 + i.days, user: paul)   }
          week_2_paul_1_x_7.flatten!

          week_2_george_1_x_7 = []
          0.upto(6) { |i| week_2_george_1_x_7 << FactoryGirl.create_list(:act, 1, demo: demo, created_at: week_2 + i.days, user: george) }
          week_2_george_1_x_7.flatten!

          week_2_ringo_1_x_7  = []
          0.upto(6) { |i| week_2_ringo_1_x_7 << FactoryGirl.create_list(:act, 1, demo: demo, created_at: week_2 + i.days, user: ringo)  }
          week_2_ringo_1_x_7.flatten!

          acts_hash[week_2] = week_2_john_1_x_7 + week_2_paul_1_x_7 + week_2_george_1_x_7 + week_2_ringo_1_x_7

          # Nothing for week_3 ----------------------------------------------

          # 1 creates multiple and 1 creates 1 -------------------------------
          week_4_john_5_x_7   = []
          0.upto(6) { |i| week_4_john_5_x_7 << FactoryGirl.create_list(:act, 5, demo: demo, created_at: week_4 + i.days, user: john) }
          week_4_john_5_x_7.flatten!

          week_4_paul_1_x_7   = []
          0.upto(6) { |i| week_4_paul_1_x_7 << FactoryGirl.create_list(:act, 1, demo: demo, created_at: week_4 + i.days, user: paul) }
          week_4_paul_1_x_7.flatten!

          acts_hash[week_4] = week_4_john_5_x_7 + week_4_paul_1_x_7

          # 1 creates multiple -------------------------------
          week_5_george_3_x_7 = []
          0.upto(6) { |i| week_5_george_3_x_7 << FactoryGirl.create_list(:act, 3, demo: demo, created_at: week_5 + i.days, user: george) }
          week_5_george_3_x_7.flatten!

          acts_hash[week_5] = week_5_george_3_x_7

          # 1 creates 1 -------------------------------
          week_6_ringo_1_x_7  = []
          0.upto(6) { |i| week_6_ringo_1_x_7 << FactoryGirl.create_list(:act, 1, demo: demo, created_at: week_6 + i.days, user: ringo) }
          week_6_ringo_1_x_7.flatten!

          acts_hash[week_6] = week_6_ringo_1_x_7

          weekly = Highchart::Weekly.new(demo, '7/21/2012', '9/1/2012', true, true)
          a_points, u_points = weekly.data_points

          # Calculations -------------------------------------
          weekly.calculate_number_per_time_interval(acts_hash)

          # Read 'em and weep (Hopefully) -------------------
          weekly.num_acts_per_interval[week_1].should == 77
          weekly.num_users_per_interval[week_1].should == 4

          weekly.num_acts_per_interval[week_2].should == 28
          weekly.num_users_per_interval[week_2].should == 4

          weekly.num_acts_per_interval[week_3].should be_nil
          weekly.num_users_per_interval[week_3].should be_nil

          weekly.num_acts_per_interval[week_4].should == 42
          weekly.num_users_per_interval[week_4].should == 2

          weekly.num_acts_per_interval[week_5].should == 21
          weekly.num_users_per_interval[week_5].should == 1

          weekly.num_acts_per_interval[week_6].should == 7
          weekly.num_users_per_interval[week_6].should == 1
        end
      end
    end
  end
end
