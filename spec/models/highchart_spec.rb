require 'spec_helper'

describe 'Highchart#convert_date' do
  it "should convert a 'day/month/year' string to a 'month/day/year' DateTime" do
    expect(Highchart.convert_date('12/24/2012')).to eq('24/12/2012'.to_datetime)

    expect(Highchart.convert_date('01/02/2012')).to eq('02/01/2012'.to_datetime)

    expect(Highchart.convert_date('7/4/2012')).to eq('4/7/2012'.to_datetime)

    expect(Highchart.convert_date('11/6/2012')).to eq('6/11/2012'.to_datetime)
  end
end

describe 'A group of tests...' do

  describe 'Hourly#data_points' do
    it 'should return the right number of acts and users' do
      demo = FactoryGirl.create :demo

      start_date = '12/25/2012'
      end_date   = '12/25/2012'

      start_boundary = Highchart.convert_date(start_date).beginning_of_day.to_time.localtime
      end_boundary   = Highchart.convert_date(end_date).end_of_day.to_time.localtime

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

      chart = Highchart::Hourly.new(demo, start_date, end_date, true, true)
      act_points, user_points = chart.data_points

      # Both 'act_points' and 'user_points' look like: { 0=>2, 1=>1, 3=>1, 4=>1, 5=>6, 6=>2, 7=>2, 8=>4, 9=>3, 10=>5, ... }
      num_acts  = act_points.values.sum
      num_users = user_points.values.sum

      expect(num_acts).to eq(8)
      expect(num_users).to eq(8)

      expect(demo.acts.count).to eq(16)  # Make sure the bad acts were created

      # Make sure each hour contains the correct number of acts and users
      # (Boundary hour got acts for +/- 1- and 2-minutes, while inner hours got just one act per hour)
      [start_boundary, start_boundary + 1.hour, start_boundary + 2.hours,
       end_boundary,   end_boundary - 1.hour,   end_boundary - 2.hours].each do |time|
        act_points[time.hour % 24].should  == ((time == start_boundary or time == end_boundary) ? 2 : 1)
        user_points[time.hour % 24].should == ((time == start_boundary or time == end_boundary) ? 2 : 1)
      end

      # Make sure no other hours snuck into the grouping hash
      act_points.keys.count.should  == 24
      user_points.keys.count.should == 24
    end
  end

  describe 'Daily#data_points' do
    it 'should return the right number of acts and users' do
      demo = FactoryGirl.create :demo

      # Pick days that not only straddle a month, but a year as well
      start_date = '12/25/2012'
      end_date   = '01/16/2013'

      start_boundary = Highchart.convert_date(start_date).beginning_of_day
      end_boundary   = Highchart.convert_date(end_date).end_of_day

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

      chart = Highchart::Daily.new(demo, start_date, end_date, true, true)
      act_points, user_points = chart.data_points

      # Both 'act_points' and 'user_points' look like:
      # {Tue, 25 Dec 2012=>2, Wed, 26 Dec 2012=>1, ... Sun, 30 Dec 2012=>0, Mon, 31 Dec 2012=>0, Tue, 01 Jan 2013=>0, Wed, 02 Jan 2013=>0, ...}
      num_acts  = act_points.values.sum
      num_users = user_points.values.sum

      num_acts.should  == 8
      num_users.should == 8

      demo.acts.count.should == 16  # Make sure the bad acts were created

      # Make sure each day contains the correct number of acts and users
      # (Boundary days got acts for +/- 1- and 2-minutes, while inner days got just one act per day)
      [start_boundary, start_boundary + 1.day, start_boundary + 2.days,
       end_boundary,   end_boundary - 1.day,   end_boundary - 2.days].each do |day|
        act_points[day.to_date].should  == ((day == start_boundary or day == end_boundary) ? 2 : 1)
        user_points[day.to_date].should == ((day == start_boundary or day == end_boundary) ? 2 : 1)
      end

      # Make sure no other days snuck into the grouping hash
      act_points.keys.count.should  == 23
      user_points.keys.count.should == 23
    end
  end

  # The weekly plot gets a little confusing, so here's a visual representation of what we are dealing with.
  # Remember, the range is Dec. 25 thru Jan 16. These days were picked to not only straddle both a month
  # and a year, but to test the weekly view's "problem end points".
  # Also, when Postgresql groups weeks it assumes they start on Monday => this grouping actually "backs up" to start on Dec 24th.

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
  20  21  22  23  24  25  26
=end

  describe 'Weekly#data_points' do
    it 'should return the right number of acts and users' do
      demo = FactoryGirl.create :demo

      # Pick days that not only straddle a month, but a year as well
      start_date = '12/25/2012'
      end_date   = '01/16/2013'

      start_boundary = Highchart.convert_date(start_date).beginning_of_day
      end_boundary   = Highchart.convert_date(end_date).end_of_day

      # Create some acts that lie outside the input range... but some will end up in the results (see comments below)
      (1..2).each do |i|
        # These 2 are in Dec. 24th, which means that thanks to the way Postgresql groups weeks, they should end up in the results
        FactoryGirl.create :act, demo: demo, created_at: start_boundary - i.minutes
        FactoryGirl.create(:act, demo: demo, created_at: start_boundary - i.hours)

        # These 2 are in Dec. 23rd => they should not show up in the results
        FactoryGirl.create :act, demo: demo, created_at: start_boundary - 1.day - i.minutes
        FactoryGirl.create(:act, demo: demo, created_at: start_boundary - 1.day - i.hours)

        # These 2 are in Jan. 17th => should end up in the results for the week of Jan. 14
        FactoryGirl.create :act, demo: demo, created_at: end_boundary + i.minutes
        FactoryGirl.create(:act, demo: demo, created_at: end_boundary + i.hours)

        # These 2 are in Jan 21st => should not show up in the results
        FactoryGirl.create :act, demo: demo, created_at: end_boundary + 4.days + i.minutes
        FactoryGirl.create(:act, demo: demo, created_at: end_boundary + 4.days + i.hours)
      end

      # Create some acts that just lie within the boundary days by minutes and also some that land squarely within the range
      in_range_acts = []
      (1..2).each do |i|
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: start_boundary + i.minutes)  # In Dec 25
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: end_boundary - i.minutes)    # In Jan 16

        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: start_boundary + i.days)     # In Dec 26
        in_range_acts << FactoryGirl.create(:act, demo: demo, created_at: end_boundary - i.days)       # In Jan 15
      end

      # Okay, after all of the above nonsense, here are the number of acts that we should have in each day/group:
      #
      # Dec 23: 4
      # ---------  Dec. 24 group
      # Dec 24: 4
      # Dec 25: 2
      # Dec 26: 2
      # ---------  Dec 31 group
      # ---------  Jan  7 group
      # ---------  Jan 14 group
      # Jan 15: 2
      # Jan 16: 2
      # ---------  Part of Jan 14 group, but end date is Jan 16 => should not be counted
      # Jan 17: 2
      # ---------  Jan 21 group
      # Jan 21: 2

      chart = Highchart::Weekly.new(demo, start_date, end_date, true, true)
      act_points, user_points = chart.data_points

      # Both 'act_points' and 'user_points' look like:
      # {Mon, 24 Dec 2012=>8, Mon, 31 Dec 2012=>0, Mon, 07 Jan 2013=>0, Mon, 14 Jan 2013=>4}
      num_acts  = act_points.values.sum
      num_users = user_points.values.sum

      num_acts.should  == 12
      num_users.should == 12

      demo.acts.count.should == 24  # Make sure the bad acts were created

      postgres_adjusted_start_day = start_boundary - 1.day  # Postgresql considers weeks to start on Monday

      act_points[postgres_adjusted_start_day].should  == 8
      user_points[postgres_adjusted_start_day].should == 8

      act_points[postgres_adjusted_start_day + 3.weeks].should  == 4
      user_points[postgres_adjusted_start_day + 3.weeks].should == 4

      # Make sure no other weeks snuck into the grouping hash. (Should be Dec 24, Dec 31, Jan 7, Jan 14)
      act_points.keys.count.should  == 4
      user_points.keys.count.should == 4

      act_points.keys.each_with_index  { |day, i| day.should == postgres_adjusted_start_day + i.weeks }
      user_points.keys.each_with_index { |day, i| day.should == postgres_adjusted_start_day + i.weeks }
    end
  end
end

describe 'Yet another group of tests...' do
  let(:demo)   { FactoryGirl.create :demo }

  let(:john)   { FactoryGirl.create :user, demo: demo }
  let(:paul)   { FactoryGirl.create :user, demo: demo }
  let(:george) { FactoryGirl.create :user, demo: demo }
  let(:ringo)  { FactoryGirl.create :user, demo: demo }

  let(:acts_hash) { {} }

  Y = Struct.new(:acts, :users)  # Simplifies creating hash of expected values

  # Okay, here's the deal: Hourly mode => all acts have to be within a 1-day, 24-hour period because that's how the query
  # fetches them. Not only that, but for this (and other) tests, we create acts around the "end points" of the day as
  # opposed to the "meat" of the day because that's where the more-complicated test cases arise. (Creating all acts
  # around 2 or 3 in the afternoon, while easier, wouldn't convince me that this code is thoroughly tested.)
  #
  # 'Hourly' is also a royal pain in the ass because Rails stores all times in UTC which is 4 or 5 hours ahead of EST,
  # depending on whether or not it is Daylight Savings time.
  #
  # We found a bug in Hourly where the times were off by 4 or 5 hours; the fix was to re-adjust the times back to EST.
  # What's that got to do with this test? Well, this test was set up to process acts that lived at the edges of a
  # 24-hour window. But when you adjust for the 5-hour difference... well, now those acts no longer live within that window.
  #
  # To make the 5-hour adjustment in the simplest, most understandable manner I did the following:
  # 1) Added 5 hours to the lower-level hours (1am, 2am, 3am) => they will still live within the 24-hour window.
  # 2) Unfortunately, doing the same thing to the higher-lever hours (9pm, 10pm, 11pm) would knock those guys out
  #    of the 24-hour window, so 5 hours gets subtracted from them down below in the 'y-values' hash.
  #
  # And if Phil ever assigns me *anything time-related in Rails* again.. well, he's bigger than me so I probably won't do anything.

  describe 'Hourly#data_points', focus: true do
    it 'should return the right number of acts and users' do
      day = Highchart.convert_date('11/11/2012')
      hour_1  = day + 1.hours + 5.hours
      hour_2  = day + 2.hours + 5.hours
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

      # Create an Hourly object to process these acts
      hourly = Highchart::Hourly.new(demo, '11/11/2012', '11/11/2012', true, true)
      act_points, user_points = hourly.data_points

      # Keys are x-values we are expecting y-values for. Define these expected (act, user) y-values.
      # For all other x-values both the 'act' and 'user' y-value should be 0.
      # For the reason why 5 is subtracted for some of the keys, see comments at beginning of this test.
      #
      y_values = Hash[1  => Y.new(11, 4),
                      2  => Y.new(4, 4),
                      (21 - 5) => Y.new(6, 2),
                      (22 - 5) => Y.new(3, 1),
                      (23 - 5) => Y.new(1, 1)]

      y_values.default = Y.new(0, 0)

      0.upto(23) do |hour|
        expect(act_points[hour]).to eq(y_values[hour].acts)
        expect(user_points[hour]).to eq(y_values[hour].users)
      end
    end
  end

  describe 'Daily#data_points' do
    it 'should return the right number of acts and users' do
      day_1 = Highchart.convert_date('7/1/2012')
      day_2 = Highchart.convert_date('7/4/2012')
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

      # Create a Daily object to process these acts
      daily = Highchart::Daily.new(demo, '7/1/2012', '7/31/2012', true, true)
      act_points, user_points = daily.data_points

      # Keys are x-values we are expecting y-values for. Define these expected (act, user) y-values.
      # For all other x-values both the 'act' and 'user' y-value should be 0.
      y_values = Hash[day_1 => Y.new(11, 4),
                      day_2 => Y.new(4, 4),
                      day_4 => Y.new(6, 2),
                      day_5 => Y.new(3, 1),
                      day_6 => Y.new(1, 1)]
      y_values.default = Y.new(0, 0)

      (day_1..day_6).each do |day|
        act_points[day].should  == y_values[day].acts
        user_points[day].should == y_values[day].users
      end
    end
  end

  describe 'Weekly#data_points' do
    it 'should return the right number of acts and users' do
      # Will actually be 7/16/2012 because Postgresql groups weeks by starting-on-previous-monday
      week_1 = Highchart.convert_date('7/21/2012').beginning_of_week
      week_2 = week_1 + 7.days  # 7/23/2012
      week_3 = week_2 + 7.days  # 7/30/2012
      week_4 = week_3 + 7.days  # 8/6/2012
      week_5 = week_4 + 7.days  # 8/13/2012
      week_6 = week_5 + 7.days  # 8/20/2012

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

      # Create an Weekly object to process these acts
      weekly = Highchart::Weekly.new(demo, '7/21/2012', '9/1/2012', true, true)
      act_points, user_points = weekly.data_points

      # Keys are x-values we are expecting y-values for. Define these expected (act, user) y-values.
      # For all other x-values both the 'act' and 'user' y-value should be 0.
      y_values = Hash[week_1 => Y.new(77, 4),
                      week_2 => Y.new(28, 4),
                      week_4 => Y.new(42, 2),
                      week_5 => Y.new(21, 1),
                      week_6 => Y.new(7, 1)]
      y_values.default = Y.new(0, 0)

      # Can't just step up to 'week_6' because that is '8/25/2012' => Step up to the actual end date (just like the code does)
      (week_1..Highchart.convert_date('9/1/2012').end_of_day).step(7) do |week|
        act_points[week].should  == y_values[week].acts
        user_points[week].should == y_values[week].users
      end
    end
  end
end
