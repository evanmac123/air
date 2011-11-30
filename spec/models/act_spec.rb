require 'spec_helper'

describe Act do
  it { should belong_to(:user) }
  it { should belong_to(:rule) }
  it { should belong_to(:demo) }
  it { should have_one(:goal).through(:rule) }
end

describe Act, "#points" do
  context "for an Act with inherent points" do
    it "should return that value" do
      (Factory :act, :inherent_points => 5).points.should == 5
    end
  end

  context "for an act with no inherent points that belongs to a Rule" do
    it "should return that Rule's point value" do
      rule = Factory(:rule, :points => 12)
      (Factory :act, :rule => rule).points.should == 12
    end
  end

  context "for an act with no inherent points or Rule" do
    it "should return nil" do
      (Factory :act).points.should be_nil
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
    let(:user) { Factory(:user, :phone_number => '+16175551212') }

    context "and types a good value" do
      let(:rule_value) { Factory :rule_value, :is_primary => true, :rule => (Factory :rule, :demo => user.demo) }
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
          rule.demo = Factory :demo
          rule.save!
        end

        it "should decline to recognize that" do
          Act.parse(user, good_sms).should include("Sorry, I don't understand what that means.")
        end
      end
    end
  end
end

describe Act, ".find_and_record_rule_suggestion" do
  before(:each) do
    @demo = Factory :demo

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
      Factory :rule_value, :value => value, :is_primary => true, :rule => (Factory :rule, :demo => @demo)
    end

    @user = Factory :user, :demo => @demo
  end

  context "when nothing matches well" do
    it "should return a canned message" do
      Act.send(:find_and_record_rule_suggestion, 'played guitar', @user).should == "Sorry, I don't understand what that means. @{Say} \"s\" to suggest we add what you sent."
    end
  end

  context "when something matches but it's not in the same demo" do
    it "should return a canned message" do
      rule_value = Factory :rule_value, :value => 'played football'
      rule_value.demo.should_not == @demo

      Act.send(:find_and_record_rule_suggestion, 'played guitar', @user).should == "Sorry, I don't understand what that means. @{Say} \"s\" to suggest we add what you sent."
    end
  end

  context "when one thing matches well" do
    before(:each) do
      @result = Act.send(:find_and_record_rule_suggestion, 'pet kitten', @user)
    end

    it "should return an appropriate phrase" do
      @result.should == "I didn't quite get that. @{Say} \"a\" for \"ate kitten\", or \"s\" to suggest we add what you sent."
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
      @result.should == "I didn't quite get that. @{Say} \"a\" for \"ate an entire pizza\", \"b\" for \"ate banana\", \"c\" for \"ate kitten\", or \"s\" to suggest we add what you sent."
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

