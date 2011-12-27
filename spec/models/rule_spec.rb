require 'spec_helper'

describe Rule do
  subject { Factory(:rule) }

  it { should belong_to(:demo) }
  it { should belong_to(:goal) }
  it { should have_many(:acts) }
  it { should have_many(:rule_values) }
  it { should have_many(:rule_triggers) }

  describe "#to_s" do
    before(:each) do
      @rule = Factory :rule
      rv1 = Factory :rule_value, :value => 'engendered healthificity', :rule => @rule
      rv2 = Factory :rule_value, :value => 'made a healthiness', :rule => @rule, :is_primary => true

      (rv1.created_at < rv2.created_at).should be_true
    end

    context "when no description is set" do
      context "but a primary RuleValue exists" do
        it "should use the value of the primary RuleValue" do
          @rule.to_s.should == "made a healthiness"
        end
      end

      context "and no primary RuleValue exists" do
        it "should use the value of the oldest RuleValue" do
          primary_value = @rule.primary_value
          primary_value.is_primary = false
          primary_value.save!

          @rule.reload.primary_value.should be_nil
          @rule.to_s.should == "engendered healthificity"
        end
      end
    end

    context "when a description is set" do
      it "should use that" do
        @rule.description = "Made health"
        @rule.to_s.should == "Made health"
      end
    end
  end

  describe "#primary_value" do
    before(:each) do
      @rule = Factory :rule
    end

    context "when the rule has no values" do
      before(:each) do
        @rule.rule_values.should be_empty
      end

      it "should return nil" do
        @rule.primary_value.should be_nil
      end
    end

    context "when the rule has values, none of which are primary" do
      before(:each) do
        3.times {Factory :rule_value, :is_primary => false, :rule => @rule}
      end

      it "should return nil" do
        @rule.primary_value.should be_nil
      end
    end

    context "when the rule has a primary value" do
      before(:each) do
        3.times {Factory :rule_value, :is_primary => false, :rule => @rule}
        @primary_value = Factory :rule_value, :is_primary => true, :rule => @rule
      end

      it "should return that value" do
        @rule.primary_value.should == @primary_value
      end
    end
  end
end
