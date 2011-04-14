require 'spec_helper'

describe Rule do
  subject { Factory(:rule) }

  it { should have_many(:acts) }

  it { should validate_presence_of(:value) }
  it { should validate_uniqueness_of(:value) }

  describe "#to_s" do
    before(:each) do
      @rule = Factory :rule, :value => 'engendered healthificity'
    end

    context "when no description is set" do
      it "should be made from the name of the key and the value of the rule" do
        @rule.to_s.should == "engendered healthificity"
      end
    end

    context "when a description is set" do
      it "should use that" do
        @rule.description = "Made health"
        @rule.to_s.should == "Made health"
      end
    end
  end

  describe "before save" do
    it "should normalize the value" do
      rule = Factory.build :rule, :value => '   FoO    BaR '
      rule.save!
      rule.value.should == 'foo bar'
    end
  end
end
