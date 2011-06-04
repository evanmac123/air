require 'spec_helper'

describe BonusThreshold do
  it { should validate_presence_of :award }
  it { should validate_presence_of :min_points }
  it { should validate_presence_of :max_points }
  it { should validate_presence_of :demo_id }

  it "should require max_points to be greater or equal than min_points" do
    min_points_less = Factory.build(:bonus_threshold, :min_points => 5, :max_points => 10)
    min_points_equal = Factory.build(:bonus_threshold, :min_points => 10, :max_points => 10)
    min_points_greater = Factory.build(:bonus_threshold, :min_points => 11, :max_points => 10)

    min_points_less.should be_valid
    min_points_equal.should be_valid
    min_points_greater.should_not be_valid

    min_points_greater.errors[:min_points].should_not be_empty
  end

  describe "#award_points?" do
    context "when a user has already passed this threshold" do
      it "should always return false" do
        bonus_threshold = Factory :bonus_threshold
        user = Factory :user, :points => bonus_threshold.max_points + 1
        user.bonus_thresholds << bonus_threshold

        bonus_threshold.award_points?(user).should be_false
      end
    end

    context "when passed a user with less than min_points" do
      it "should always return false" do
        1.upto(10) do |i|
          bonus_threshold = Factory :bonus_threshold, :min_points => i, :max_points => 20
          bonus_threshold.award_points?(Factory :user, :points => i - 1).should be_false
        end
      end
    end

    context "when passed a score equal to or greater than max_points" do
      it "should always return true" do
        1.upto(10) do |i|
          bonus_threshold = Factory :bonus_threshold, :min_points => 0, :max_points => i
          bonus_threshold.award_points?(Factory :user, :points => i).should be_true
          bonus_threshold.award_points?(Factory :user, :points => i + 1).should be_true
        end
      end
    end

    context "when passed a score greater than min_points and less than max_points" do
      it "should have a chance of returning true proportional to how deep into the min_points/max_points spread the score is" do
        bonus_threshold = Factory :bonus_threshold, :min_points => 1, :max_points => 10

        1.upto(9) do |score|
          0.upto(score - 1) do |low_random_number| # or not so random
            bonus_threshold.stubs(:rand).with(10).returns(low_random_number)
            bonus_threshold.award_points?(Factory :user, :points => score).should be_true, "score of #{score}, random number of #{low_random_number} should get award"
          end

          score.upto(9) do |high_random_number|
            bonus_threshold.stubs(:rand).with(10).returns(high_random_number)
            bonus_threshold.award_points?(Factory :user, :points => score).should be_false, "score of #{score}, random number of #{high_random_number} should not get award"
          end
        end
      end
    end
  end
end
