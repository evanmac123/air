require 'spec_helper'

describe Act do
  it { should belong_to(:user) }
  it { should belong_to(:referring_user) }
  it { should belong_to(:demo) }
end

describe Act, "#points" do
  context "for an Act with inherent points" do
    it "should return that value" do
      (FactoryGirl.create :act, :inherent_points => 5).points.should == 5
    end
  end

  context "for an act with no inherent points" do
    it "should return 0" do
      (FactoryGirl.create :act).points.should == 0
    end
  end
end
