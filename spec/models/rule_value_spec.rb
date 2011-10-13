require 'spec_helper'

describe RuleValue do
  subject {Factory :rule_value}

  it { should have_one(:demo) }
  it { should validate_presence_of(:value) }

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

