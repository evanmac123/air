require 'spec_helper'

describe RuleValue do
  subject {FactoryGirl.create :rule_value}

  it { should have_one(:demo) }
  it { should validate_presence_of(:value) }

  it "should validate that the value is unique within the demo" do
    demo = FactoryGirl.create :demo
    rule1 = FactoryGirl.create :rule, :demo => demo
    rule2 = FactoryGirl.create :rule, :demo => demo
    rv1 = FactoryGirl.create :rule_value, :rule => rule1
    rv2 = FactoryGirl.build :rule_value, :value => rv1.value, :rule => rule2
    rv2.should_not be_valid
    rv2.errors[:value].should_not be_empty
  end

  it "should validate that the value has more than one character (though a single digit is OK)" do
    valid_chars = %w(0 1 2 3 4 5 6 7 8 9)
    invalid_chars = %w(a b q k o [ ^)

    valid_chars.each {|valid_char| FactoryGirl.build(:rule_value, :value => valid_char).should be_valid}

    invalid_chars.each do |invalid_char|
      rule_value = FactoryGirl.build(:rule_value, :value => invalid_char)
      rule_value.should_not be_valid
      rule_value.errors[:value].should include("Can't have a single-character value, those are reserved for other purposes.")
    end
  end

  describe "before save" do
    it "should normalize the value" do
      rule_value = FactoryGirl.build :rule_value, :value => '   FoO    BaR '
      rule_value.save!
      rule_value.value.should == 'foo bar'
    end
  end
end

describe RuleValue, "when is_primary is true" do
  it "should validate only if the associated Rule has no other primary RuleValue" do
    rule_with_single_primary = FactoryGirl.create :rule
    rule_with_two_primaries = FactoryGirl.create :rule

    unique_primary = FactoryGirl.build :rule_value, :rule => rule_with_single_primary, :is_primary => true
    FactoryGirl.create :rule_value, :rule => rule_with_two_primaries, :value => "the real primary", :is_primary => true
    redundant_primary = FactoryGirl.build :rule_value, :rule => rule_with_two_primaries, :is_primary => true

    unique_primary.should be_valid
    redundant_primary.should_not be_valid
    redundant_primary.errors[:base].should include("Can't add a second primary value to a rule (has primary value: the real primary)")
  end
end

