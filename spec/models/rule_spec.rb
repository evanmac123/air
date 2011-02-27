require 'spec_helper'

describe Rule do
  subject { Factory(:rule) }

  it { should belong_to(:key) }

  it { should validate_presence_of(:key_id) }
  it { should validate_presence_of(:value) }
  it { should validate_uniqueness_of(:value).scoped_to(:key_id) }

  describe "#to_s" do
    before(:each) do
      @key = Factory :key, :name => 'engendered'
      @rule = Factory :rule, :value => 'healthificity', :key => @key
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
end
