require 'spec_helper'

describe RuleValue do
  subject {Factory :rule_value}

  it { should have_one(:demo) }
  it { should validate_presence_of(:value) }
  it { should validate_presence_of(:rule_id) }

  it "should validate that the value is unique within the demo" do
    demo = Factory :demo
    rule1 = Factory :rule, :demo => demo
    rule2 = Factory :rule, :demo => demo
    rv1 = Factory :rule_value, :rule => rule1
    rv2 = Factory.build :rule_value, :value => rv1.value, :rule => rule2
    rv2.should_not be_valid
    rv2.errors[:value].should_not be_empty
  end

  it "should validate that the value has more than one character" do
    rule_value = Factory.build :rule_value, :value => 'q'

    rule_value.should_not be_valid
    rule_value.errors[:value].should include("Can't have a single-character value, those are reserved for other purposes.")
  end

  describe "before save" do
    it "should normalize the value" do
      rule_value = Factory.build :rule_value, :value => '   FoO    BaR '
      rule_value.save!
      rule_value.value.should == 'foo bar'
    end
  end
end

describe RuleValue, "when is_primary is true" do
  it "should validate only if the associated Rule has no other primary RuleValue" do
    rule_with_single_primary = Factory :rule
    rule_with_two_primaries = Factory :rule

    unique_primary = Factory.build :rule_value, :rule => rule_with_single_primary, :is_primary => true
    Factory :rule_value, :rule => rule_with_two_primaries, :value => "the real primary", :is_primary => true
    redundant_primary = Factory.build :rule_value, :rule => rule_with_two_primaries, :is_primary => true

    unique_primary.should be_valid
    redundant_primary.should_not be_valid
    redundant_primary.errors[:base].should include("Can't add a second primary value to a rule (has primary value: the real primary)")
  end
end

describe RuleValue, ".find_and_record_rule_suggestion" do
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
    it "should return nil" do
      RuleValue.send(:find_and_record_rule_suggestion, 'played guitar', @user).should be_nil
    end
  end

  context "when something matches but it's not in the same demo" do
    it "should return nil" do
      rule_value = Factory :rule_value, :value => 'played football'
      rule_value.demo.should_not == @demo

      RuleValue.send(:find_and_record_rule_suggestion, 'played guitar', @user).should be_nil
    end
  end

  context "when one thing matches well" do
    before(:each) do
      @result = RuleValue.send(:find_and_record_rule_suggestion, 'pet kitten', @user)
    end

    it "should return an appropriate phrase" do
      @result.should == "I didn't quite get that. Text \"a\" for \"ate kitten\", or \"s\" to suggest we add what you sent."
    end

    it "should set the user's last suggested rules" do
      @user.reload.last_suggested_items.should == RuleValue.find_by_value('ate kitten').id.to_s
    end
  end

  context "when more than one thing matches well" do
    before(:each) do
    end

    it "should return an appropriate phrase" do
      @result = RuleValue.send(:find_and_record_rule_suggestion, 'ate raisins', @user)
      @result.should == "I didn't quite get that. Text \"a\" for \"ate an entire pizza\", \"b\" for \"ate banana\", \"c\" for \"ate kitten\", or \"s\" to suggest we add what you sent."
    end

    it "should set the user's last suggested rules" do
      @result = RuleValue.send(:find_and_record_rule_suggestion, 'ate raisins', @user)
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

    RuleValue.send(:find_and_record_rule_suggestion, 'ate raisins', @user).should_not include('ate an entire pizza')
  end

  it "should ignore rules marked as not suggestible" do
    rule_value = RuleValue.find_by_value('ate an entire pizza')
    rule = rule_value.rule
    rule.suggestible = false
    rule.save!

    RuleValue.send(:find_and_record_rule_suggestion, 'ate raisins', @user).should_not include('ate an entire pizza')
  end
end

