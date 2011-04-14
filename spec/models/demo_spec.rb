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
      @demo.welcome_message(@user).should == "You've joined the #{@demo.company_name} game! Your unique ID is #{@user.sms_slug} (text MYID if you forget). To play, text to this #. Text HELP for help."
    end
  end

  context "when the demo has a custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message = "Derp derp! Let's play!"
    end

    it "should use that" do
      @demo.welcome_message(@user).should == "Derp derp! Let's play!"
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

    context "before the ending time" do
      before(:each) do
        Timecop.freeze(Time.parse("2010-05-01 11:59:59 UTC"))
      end

      it "should return false" do
        @demo.game_over?.should be_false
      end
    end

    context "after that ending time" do
      before(:each) do
        Timecop.freeze(Time.parse("2010-05-01 12:00:00 UTC"))
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
    @all_users.stubs(:ranked).returns(@all_users)
    @all_users.stubs(:order).with('recent_average_points DESC').returns(@all_users)

    @scores_to_update_to = [100, 95, 95, 90, 85, 85, 85, 80]
    @all_users.each_with_index do |user, i| 
      score_to_update_to = @scores_to_update_to[i]
      user.expects(:recalculate_moving_average!).add_side_effect(RecalculateMovingAverageSideEffect.new(user, score_to_update_to))
    end
  end

  it "should recalculate moving average scores on all users in the demo and rank them appropriately" do
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

      HoptoadNotifier.stubs(:notify).with(anything)

      Demo.recalculate_all_moving_averages!
    end

    it "should keep going even if one demo has errors" do
      @demos.each {|demo| demo.should have_received(:recalculate_all_moving_averages!)}
    end

    it "should report the error to Hoptoad" do
      HoptoadNotifier.should have_received(:notify).with(@recalculation_error)
    end
  end
end

describe Demo, ".alphabetical" do
  before do
    @red_sox  = Factory(:demo, :company_name => "Red Sox")
    @gillette = Factory(:demo, :company_name => "Gillette")
  end

  it "finds all demos, sorted alphaetically" do
    Demo.alphabetical.should == [@gillette, @red_sox]
  end
end
