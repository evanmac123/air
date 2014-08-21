require 'spec_helper'

describe FollowUpDigestEmail do
  describe '#follow_up_days' do
    it "returns 0 when the specified day is 'Never'" do
      FollowUpDigestEmail.follow_up_days('Never').should == 0
    end

    it "returns the number of days the specified day occurs after the current day" do
      days = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

      Timecop.freeze(Time.new(2013, 11, 3))  # Sunday
      results = [7, 1, 2, 3, 4, 5, 6]
      days.each_with_index { |day, i| FollowUpDigestEmail.follow_up_days(day).should == results[i] }

      Timecop.freeze(Time.new(2013, 11, 6))  # Wednesday
      results = [4, 5, 6, 7, 1, 2, 3]
      days.each_with_index { |day, i| FollowUpDigestEmail.follow_up_days(day).should == results[i] }

      Timecop.freeze(Time.new(2013, 11, 9))  # Saturday
      results = [1, 2, 3, 4, 5, 6, 7]
      days.each_with_index { |day, i| FollowUpDigestEmail.follow_up_days(day).should == results[i] }

      Timecop.return
    end
  end
end
