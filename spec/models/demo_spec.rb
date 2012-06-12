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
  it { should have_many(:tasks) }
  it { should have_many(:self_inviting_domains) }
  it { should have_many(:locations) }
  it { should have_many(:characteristics) }
  it { should have_one(:skin) }
end

describe Demo, "when both begins_at and ends_at are set" do
  it "should validate that ends_at is later than begins_at" do
    FactoryGirl.build(:demo, :begins_at => Time.now + 2.hours, :ends_at => Time.now).should_not be_valid
  end
end

describe Demo, "#welcome_message" do
  before(:each) do
    @demo = FactoryGirl.create :demo
    @user = FactoryGirl.create :user, :demo => @demo
  end

  context "when the demo has no custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message.should be_nil
    end

    it "should return a reasonable default" do
      @demo.welcome_message(@user).should == "You've joined the #{@demo.name} game! @{reply here}"
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
    @demo = FactoryGirl.create :demo
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
    @demo = FactoryGirl.create :demo

    @first = FactoryGirl.create :user, :demo => @demo
    @second_tie_1 = FactoryGirl.create :user, :demo => @demo
    @second_tie_2 = FactoryGirl.create :user, :demo => @demo
    @fourth = FactoryGirl.create :user, :demo => @demo
    @fifth_tie_1 = FactoryGirl.create :user, :demo => @demo
    @fifth_tie_2 = FactoryGirl.create :user, :demo => @demo
    @fifth_tie_3 = FactoryGirl.create :user, :demo => @demo
    @eighth = FactoryGirl.create :user, :demo => @demo

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
end

describe Demo, ".recalculate_all_moving_averages!" do
  before(:each) do
    @demos = []
    10.times do
      demo = FactoryGirl.create :demo
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
    @red_sox  = FactoryGirl.create(:demo, :name => "Red Sox")
    @gillette = FactoryGirl.create(:demo, :name => "Gillette")
  end

  it "finds all demos, sorted alphaetically" do
    Demo.alphabetical.should == [@gillette, @red_sox]
  end
end

describe Demo, "#print_pending_friendships" do
  it "tells us how many friendships have been initiated and accepted" do 
    demo = FactoryGirl.create(:demo)
    user1 = FactoryGirl.create(:user, :demo => demo)
    user2 = FactoryGirl.create(:user, :demo => demo)
    user3 = FactoryGirl.create(:user, :demo => demo)
    user4 = FactoryGirl.create(:user, :demo => demo)
    user1.befriend user2
    user1.befriend user3
    user1.befriend user4
    user4.accept_friendship_from user1
    expected = "#{demo.name} has 3 initiated friendships, 1 of which have been accepted (33.333333333333336%)"
    demo.print_pending_friendships.should == expected


  end
end

describe Demo, "#tutorial_success" do
  before do
   @demo = FactoryGirl.create :demo
   @user1 = FactoryGirl.create :user, :demo_id => @demo.id
   @user2 = FactoryGirl.create :user, :demo_id => @demo.id
   @user3 = FactoryGirl.create :user, :demo_id => @demo.id
   tutorial1 = Tutorial.create(:user_id => @user1.id)
   tutorial2 = Tutorial.create(:user_id => @user2.id) 
  end
  
  it "finds out if we met our goals" do
    @demo.tutorial_success
    demo2 = FactoryGirl.create :demo
    demo2.tutorial_success
  end
end

describe Demo, "#email_valid_for_demo" do 
  before do
  @self_inviting_demo = Demo.create!(:name => 'game')
  @domain_1 = SelfInvitingDomain.create!(:domain => 'firstdomain.com', :demo_id => @self_inviting_demo.id)   
  @domain_2 = SelfInvitingDomain.create!(:domain => 'seconddomain.com', :demo_id => @self_inviting_demo.id)   
  @public_demo = Demo.new(:join_type => "public")
  @pre_populated_demo = Demo.new()
  end
  
  it "should do stuff" do
    @public_demo.valid_email_to_create_new_user("bogus_email@bog").should be_false
    @public_demo.valid_email_to_create_new_user("real_email@real.com").should be_true
    @self_inviting_demo.valid_email_to_create_new_user("email3@firstdomain.com").should be_true
    @self_inviting_demo.valid_email_to_create_new_user("email@seconddomain.com").should be_true
    @self_inviting_demo.valid_email_to_create_new_user("email@wrongdomain.com").should be_false
    @pre_populated_demo.valid_email_to_create_new_user("real_email@real.com").should be_false
  end
end
