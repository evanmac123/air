require 'spec_helper'

def expect_act_ping(act, properties={})
  FakeMixpanelTracker.events_matching("acted", {:distinct_id => act.user.email}.merge(properties)).should be_present
end

describe Act do
  it { should belong_to(:user) }
  it { should belong_to(:referring_user) }
  it { should belong_to(:rule) }
  it { should belong_to(:demo) }
  it { should have_one(:goal).through(:rule) }
end

describe Act, "on create" do
  it "should record a Mixpanel ping" do
    act = FactoryGirl.create :act
    Delayed::Worker.new.work_off(20)

    expect_act_ping(act)
  end

  it "should record the primary value of the related rule" do
    rule_value = FactoryGirl.create :rule_value, :value => "hey hey", :is_primary => true
    act = FactoryGirl.create :act, :rule => rule_value.rule
    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :rule_value => rule_value.value)
  end

  it "should record the tags of the related rule" do
    rule = FactoryGirl.create :rule
    rule.tags = [FactoryGirl.create(:tag, :name => "woo"), FactoryGirl.create(:tag, :name => "all right"), FactoryGirl.create(:tag, :name => "how about that")]

    act = FactoryGirl.create :act, :rule => rule

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :primary_tag => rule.primary_tag.name, :secondary_tags => ["all right", "how about that", "woo"])
  end

  it "should record what game the user is in" do
    act = FactoryGirl.create :act

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :game => act.user.demo.name)
  end

  it "should record the number of followers the user has" do
    user = FactoryGirl.create :user

    5.times {FactoryGirl.create :friendship, :friend => user, :state => 'accepted'}
    10.times {FactoryGirl.create :friendship, :friend => user, :state => 'pending'}

    act = FactoryGirl.create :act, :user => user

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :followers_count => 5)
  end

  it "should record the number of users the user is following" do
    user = FactoryGirl.create :user

    3.times {FactoryGirl.create :friendship, :user => user, :state => 'accepted'}
    10.times {FactoryGirl.create :friendship, :user => user, :state => 'pending'}

    act = FactoryGirl.create :act, :user => user

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :following_count => 3)
  end

  it "should record the user's level" do
    demo = FactoryGirl.create :demo
    [10,20,30].each {|threshold| FactoryGirl.create :level, :demo => demo, :threshold => threshold}
    user = FactoryGirl.create :user, :demo => demo

    act = FactoryGirl.create :act, :user => user, :inherent_points => 17
    user.top_level_index.should == 2

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :level_index => 2)
  end

  it "should record the user's score" do
    user = FactoryGirl.create :user
    act = FactoryGirl.create :act, :user => user, :inherent_points => 47

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :score => 47)
  end
 
  it "should record the user's account creation date" do
    user = FactoryGirl.create :user

    user.update_attributes(:created_at => Chronic.parse("March 17, 2009, 6:23 AM"))
    act = FactoryGirl.create :act, :user => user, :inherent_points => 47

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :account_creation_date => Date.parse("2009-03-17"))
  end

  it "should record the tagged user" do
    other_user = FactoryGirl.create :user

    act = FactoryGirl.create :act, :referring_user => other_user

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :tagged_user_id => other_user.id)
  end

  it "should record the channel" do
    act = FactoryGirl.create :act, :creation_channel => :magic

    Delayed::Worker.new.work_off(20)

    expect_act_ping(act, :channel => :magic)
  end

  it "should record if it was created by suggestion" do
    user = FactoryGirl.create :user
    rule_value_1 = FactoryGirl.create :rule_value, :is_primary => true
    rule_value_2 = FactoryGirl.create :rule_value, :is_primary => true
    rule_value_3 = FactoryGirl.create :rule_value, :is_primary => true

    user.update_attributes(:last_suggested_items => [rule_value_1.id, rule_value_2.id, rule_value_3.id].join('|'))
    SpecialCommand.parse(user, 'b', {})

    act = Act.last
    act.rule.primary_value.should == rule_value_2
   
    Delayed::Worker.new.work_off(10)
    expect_act_ping(act, :suggestion_code => 'b')
  end

  it "should record the date the associated user accepted their invitation" do
    user = FactoryGirl.create :user
    user.update_attributes(:accepted_invitation_at => Chronic.parse("March 23, 2009, 6:23 AM"))

    act = FactoryGirl.create :act, :user => user
    Delayed::Worker.new.work_off(10)
    expect_act_ping(act, :joined_game_date => Date.parse('2009-03-23'))
  end
end

describe Act, "#points" do
  context "for an Act with inherent points" do
    it "should return that value" do
      (FactoryGirl.create :act, :inherent_points => 5).points.should == 5
    end
  end

  context "for an act with no inherent points that belongs to a Rule" do
    it "should return that Rule's point value" do
      rule = FactoryGirl.create(:rule, :points => 12)
      (FactoryGirl.create :act, :rule => rule).points.should == 12
    end
  end

  context "for an act with no inherent points or Rule" do
    it "should return nil" do
      (FactoryGirl.create :act).points.should be_nil
    end
  end
end

describe Act, ".parse" do
  context "when user has not been invited to the game" do
    it "tells them" do
      number = "+14155551212"
      User.find_by_phone_number(number).should be_nil

      reply = "I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\")."      
      Act.parse(number, "hello?").should == reply
    end
  end

  context "when user is in the game" do
    let(:user) { FactoryGirl.create(:user, :phone_number => '+16175551212') }

    context "and types a good value" do
      let(:rule_value) { FactoryGirl.create :rule_value, :is_primary => true, :rule => (FactoryGirl.create :rule, :demo => user.demo) }
      let(:rule)       { rule_value.rule }
      let(:good_sms)   { rule.primary_value.value }

      before do
        @result = Act.parse(user, good_sms)
      end

      it "replies with the rule's reply" do
        @result.should include(rule.reply)
      end

      it "creates an act" do
        Act.exists?(:user_id => user.id, :text => good_sms, :rule_id => rule.id, :demo_id => user.demo_id).should be_true
      end

      it "updates users points" do
        user.reload.points.should == rule.points
      end

      context "that belongs to a different demo" do
        before(:each) do
          rule.demo = FactoryGirl.create :demo
          rule.save!
        end

        it "should decline to recognize that" do
          Act.parse(user, good_sms).should include("Sorry, I don't understand what")
        end
      end
    end

    context "and types a bad value that we can't relate to at all" do
      before do
        RuleValue.stubs(:suggestion_for).returns(["fake reply", "19|9|999"])
      end

      it "should record pertinent data in Mixpanel" do
        Act.parse(user, "did something mighty peculiar")
        user.reload.last_suggested_items.should == "19|9|999"

        Delayed::Worker.new.work_off(10)
        expected_mixpanel_properties = user.data_for_mixpanel.merge(:suggestion_a => '19', :suggestion_b => '9', :suggestion_c => '999')
        FakeMixpanelTracker.events_matching("got rule suggestion", expected_mixpanel_properties).should be_present
      end
    end
  end
end

describe Act, ".find_and_record_rule_suggestion" do
  before(:each) do
    @demo = FactoryGirl.create :demo

    [
      'ate banana',
      'ate kitten',
      'ate an entire pizza',
      'ate Sheboygan',
      'worked out',
      'drank beer',
      'drank whiskey',
      'went for a walk',
      'took a walk',
      'walked outside'
    ].each do |value| 
      FactoryGirl.create :rule_value, :value => value, :is_primary => true, :rule => (FactoryGirl.create :rule, :demo => @demo)
    end

    @user = FactoryGirl.create :user, :demo => @demo
  end

  context "when nothing matches well" do
    it "should return a canned message" do
      Act.send(:find_and_record_rule_suggestion, 'played guitar', @user).should == "Sorry, I don't understand what \"played guitar\" means. @{Say} \"s\" to suggest we add it."
    end
  end

  context "when something matches but it's not in the same demo" do
    it "should return a canned message" do
      rule_value = FactoryGirl.create :rule_value, :value => 'played football'
      rule_value.demo.should_not == @demo

      Act.send(:find_and_record_rule_suggestion, 'played guitar', @user).should == "Sorry, I don't understand what \"played guitar\" means. @{Say} \"s\" to suggest we add it."
    end
  end

  context "when one thing matches well" do
    before(:each) do
      @result = Act.send(:find_and_record_rule_suggestion, 'pet kitten', @user)
    end

    it "should return an appropriate phrase" do
      @result.should == "I didn't quite get what \"pet kitten\" means. @{Say} \"a\" for \"ate kitten\", or \"s\" to suggest we add it."
    end

    it "should set the user's last suggested rules" do
      @user.reload.last_suggested_items.should == RuleValue.find_by_value('ate kitten').id.to_s
    end
  end

  context "when more than one thing matches well" do
    before(:each) do
    end

    it "should return an appropriate phrase" do
      @result = Act.send(:find_and_record_rule_suggestion, 'ate raisins', @user)
      @result.should == "I didn't quite get what \"ate raisins\" means. @{Say} \"a\" for \"ate an entire pizza\", \"b\" for \"ate banana\", \"c\" for \"ate kitten\", or \"s\" to suggest we add it."
    end

    it "should set the user's last suggested rules" do
      @result = Act.send(:find_and_record_rule_suggestion, 'ate raisins', @user)
      expected_indices = [
        'ate an entire pizza', 
        'ate banana', 
        'ate kitten'
      ].map{|value| RuleValue.find_by_value(value)}.map(&:id)
      
      @user.reload.last_suggested_items.should == expected_indices.map(&:to_s).join('|')
    end
  end

  it "should ignore non-primary rule values" do
    rule_value = RuleValue.find_by_value('ate an entire pizza')
    rule_value.is_primary = false
    rule_value.save!

    Act.send(:find_and_record_rule_suggestion, 'ate raisins', @user).should_not include('ate an entire pizza')
  end

  it "should ignore rules marked as not suggestible" do
    rule_value = RuleValue.find_by_value('ate an entire pizza')
    rule = rule_value.rule
    rule.suggestible = false
    rule.save!

    Act.send(:find_and_record_rule_suggestion, 'ate raisins', @user).should_not include('ate an entire pizza')
  end

  context "with sloppy value entry" do
    [ " pet kitten", "pet kitten ", "pet: kitten" "pet! kitten!" ].each do |sloppy_value|
      context "like \"#{sloppy_value}\"" do
        it "should return the right thing and not raise an error" do
          Act.send(:find_and_record_rule_suggestion, sloppy_value, @user).should include("ate kitten")
        end
      end
    end
  end
end

describe Act, ".record_act" do
  before do
    @user = FactoryGirl.create :user
    @rule = FactoryGirl.create :rule, :description => 'some rule'
    @referring_user = FactoryGirl.create :user

    Act.count.should == 0
    Act.record_act(@user, @rule, :channel => :web, :referring_user => @referring_user)
    Act.count.should == 1
  end

  context "when referring_user is not nil" do
    it "should record the referring user" do
      Act.last.referring_user.should == @referring_user
    end
  end

  context "when channel is not nil" do
    it "should record the channel" do
      Act.last.creation_channel.should == "web"
    end
  end
end
