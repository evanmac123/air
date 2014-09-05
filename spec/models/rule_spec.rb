require 'spec_helper'

describe Rule do
  subject { FactoryGirl.create(:rule) }

  it { should have_one(:primary_value) }
  it { should have_many(:secondary_values) }
  it { should have_many(:rule_values).dependent(:destroy) }

  it { should belong_to(:demo) }
  it { should belong_to(:primary_tag) }

  it { should have_many(:acts) }
  it { should have_many(:tags).through(:labels) }
  it { should have_many(:rule_triggers).dependent(:destroy) }
  it { should have_many(:labels).dependent(:destroy) }

  describe "#to_s" do
    before(:each) do
      @rule = FactoryGirl.create :rule
      rv1 = FactoryGirl.create :rule_value, :value => 'engendered healthificity', :rule => @rule
      rv2 = FactoryGirl.create :rule_value, :value => 'made a healthiness', :rule => @rule, :is_primary => true
      rv1.update_attributes(created_at: 1.hour.ago)
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
      @rule = FactoryGirl.create :rule
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
        3.times {FactoryGirl.create :rule_value, :is_primary => false, :rule => @rule}
      end

      it "should return nil" do
        @rule.primary_value.should be_nil
      end
    end

    context "when the rule has a primary value" do
      before(:each) do
        3.times {FactoryGirl.create :rule_value, :is_primary => false, :rule => @rule}
        @primary_value = FactoryGirl.create :rule_value, :is_primary => true, :rule => @rule
      end

      it "should return that value" do
        @rule.primary_value.should == @primary_value
      end
    end
  end
  
  describe "#validates_length_of" do
    before(:each) do
      @rule = FactoryGirl.create(:rule, description: "Climbed the Pru")
    end

    it "should have a reply length limit of 120" do
      @rule.reply = 'H' * 120
      @rule.should be_valid
      @rule.reply = 'H' * 121
      @rule.should_not be_valid
    end
  end

  describe 'deleting a rule' do
    it 'nullifies associated acts' do
      rule = FactoryGirl.create :rule
      acts = FactoryGirl.create_list :act, 3, rule: rule

      acts.each { |act| act.rule.should_not be_nil }

      rule.destroy

      Rule.count.should == 0
      acts.each { |act| act.reload.rule.should be_nil }
    end
  end
end
