require 'spec_helper'

class RecalculateMovingAverageSideEffect
  def initialize(user, score)
    @user = user
    @score = score
  end

  def perform
    User.update_all({:recent_average_points => @score}, {:id => @user.id})
    @user.reload
  end
end

describe Demo do
  it { should have_many(:users) }
  it { should have_many(:rules) }
  it { should have_many(:rule_values).through(:rules) }
  it { should have_many(:surveys) }
  it { should have_many(:survey_questions).through(:surveys) }
  it { should have_many(:goals) }
  it { should have_many(:levels) }
  it { should have_many(:suggested_tasks) }
  it { should have_many(:self_inviting_domains) }
  it { should have_many(:locations) }
  it { should have_one(:skin) }
end

describe Demo, "when both begins_at and ends_at are set" do
  it "should validate that ends_at is later than begins_at" do
    Factory.build(:demo, :begins_at => Time.now + 2.hours, :ends_at => Time.now).should_not be_valid
  end
end

describe Demo, "#welcome_message" do
  before(:each) do
    @demo = Factory :demo
    @user = Factory :user, :demo => @demo
  end

  context "when the demo has no custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message.should be_nil
    end

    it "should return a reasonable default" do
      @demo.welcome_message(@user).should == "You've joined the #{@demo.name} game! Your username is #{@user.sms_slug} (text MYID if you forget). To play, text to this #."
    end
  end

  context "when the demo has a custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message = "Derp derp! Let's play! You are %{unique_id}, we are %{name}!"
    end

    it "should use that" do
      @demo.welcome_message(@user).should == "Derp derp! Let's play! You are #{@user.sms_slug}, we are #{@demo.name}!"
    end
  end
end

describe Demo, "#game_over?" do
  before(:each) do
    @demo = Factory :demo
  end

  context "for a demo with no ending time set" do
    before(:each) do
      @demo.ends_at.should be_nil
    end

    it "should return false" do
      @demo.game_over?.should be_false
    end
  end

  context "for a demo with an ending time set" do
    before(:each) do
      @demo.ends_at = Time.parse("2010-05-01 12:00:00 UTC")
    end

    after(:each) do
      Timecop.return
    end

    context "at or before the ending time" do
      before(:each) do
        Timecop.freeze(Time.parse("2010-05-01 12:00:00 UTC"))
      end

      it "should return false" do
        @demo.game_over?.should be_false
      end
    end

    context "after that ending time" do
      before(:each) do
        Timecop.freeze(Time.parse("2010-05-01 12:00:01 UTC"))
      end

      it "should return true" do
        @demo.game_over?.should be_true
      end
    end
  end
end

describe Demo, '#recalculate_all_moving_averages!' do
  before(:each) do
    @demo = Factory :demo

    @first = Factory :user, :demo => @demo
    @second_tie_1 = Factory :user, :demo => @demo
    @second_tie_2 = Factory :user, :demo => @demo
    @fourth = Factory :user, :demo => @demo
    @fifth_tie_1 = Factory :user, :demo => @demo
    @fifth_tie_2 = Factory :user, :demo => @demo
    @fifth_tie_3 = Factory :user, :demo => @demo
    @eighth = Factory :user, :demo => @demo

    @all_users = [@first, @second_tie_1, @second_tie_2, @fourth, @fifth_tie_1, @fifth_tie_2, @fifth_tie_3, @eighth]
    @demo.stubs(:users).returns(@all_users)
    @all_users.stubs(:claimed).returns(@all_users)
    @all_users.stubs(:order).with('recent_average_points DESC').returns(@all_users)

    @scores_to_update_to = [100, 95, 95, 90, 85, 85, 85, 80]
    @all_users.each_with_index do |user, i| 
      score_to_update_to = @scores_to_update_to[i]
      user.expects(:recalculate_moving_average!).add_side_effect(RecalculateMovingAverageSideEffect.new(user, score_to_update_to))
    end
  end

  xit "should recalculate moving average scores on all users in the demo and rank them appropriately" do
    @demo.recalculate_all_moving_averages!

    @all_users.each_with_index {|user, i| user.recent_average_points.should == @scores_to_update_to[i]}

    @first.recent_average_ranking.should == 1
    @second_tie_1.recent_average_ranking.should == 2
    @second_tie_2.recent_average_ranking.should == 2
    @fourth.recent_average_ranking.should == 4
    @fifth_tie_1.recent_average_ranking.should == 5
    @fifth_tie_2.recent_average_ranking.should == 5
    @fifth_tie_3.recent_average_ranking.should == 5
    @eighth.recent_average_ranking.should == 8
  end
end

shared_examples_for "a rankings fixing method" do
  xit "should recalculate rankings no more than once every 10 minutes" do
    Timecop.freeze

    begin
      demo1 = Factory :demo, updated_at_column => 10.minutes.ago
      demo2 = Factory :demo, updated_at_column => (9.minutes.ago - 59.seconds)
      demo3 = Factory :demo, updated_at_column => nil

      all_demos = [demo1, demo2, demo3]
      all_demos.each {|demo| demo.stubs(:fix_user_rankings!)}
      all_demos.each(&wrapper_fix_method)

      demo1.should have_received(:fix_user_rankings!).with(points_column, ranking_column)
      demo2.should_not have_received(:fix_user_rankings!)
      demo3.should have_received(:fix_user_rankings!).with(points_column, ranking_column)
    ensure
      Timecop.return
    end
  end
end

describe Demo, "#fix_total_user_rankings!" do
  let(:updated_at_column) {:total_user_rankings_last_updated_at}
  let(:points_column) {'points'}
  let(:ranking_column) {'ranking'}
  let(:wrapper_fix_method) {:fix_total_user_rankings!}
  it_should_behave_like "a rankings fixing method"
end

describe Demo, "#fix_recent_average_user_rankings!" do
  let(:updated_at_column) {:average_user_rankings_last_updated_at}
  let(:points_column) {'recent_average_points'}
  let(:ranking_column) {'recent_average_ranking'}
  let(:wrapper_fix_method) {:fix_recent_average_user_rankings!}
  it_should_behave_like "a rankings fixing method"
end

describe Demo, ".recalculate_all_moving_averages!" do
  before(:each) do
    @demos = []
    10.times do
      demo = Factory :demo
      demo.stubs(:recalculate_all_moving_averages!)
      @demos << demo
    end
    Demo.stubs(:all).returns(@demos)
  end

  it "should call #recalculate_all_moving_averages! on all existing Demos" do
    Demo.recalculate_all_moving_averages!
    @demos.each {|demo| demo.should have_received(:recalculate_all_moving_averages!)}
  end

  context "when a demo raises an error on #recalculate_all_moving_averages!" do
    before(:each) do
      @recalculation_error = RuntimeError.new("Something TERRIBLE happened")
      @demos.first.stubs(:recalculate_all_moving_averages!).raises(@recalculation_error)

      Airbrake.stubs(:notify).with(anything)

      Demo.recalculate_all_moving_averages!
    end

    it "should keep going even if one demo has errors" do
      @demos.each {|demo| demo.should have_received(:recalculate_all_moving_averages!)}
    end

    it "should report the error to Airbrake" do
      Airbrake.should have_received(:notify).with(@recalculation_error)
    end
  end
end

describe Demo, ".alphabetical" do
  before do
    @red_sox  = Factory(:demo, :name => "Red Sox")
    @gillette = Factory(:demo, :name => "Gillette")
  end

  it "finds all demos, sorted alphaetically" do
    Demo.alphabetical.should == [@gillette, @red_sox]
  end
end
