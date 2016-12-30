require 'spec_helper'

describe Act do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:referring_user) }
  it { is_expected.to belong_to(:demo) }
end

describe Act, "#points" do
  context "for an Act with inherent points" do
    it "should return that value" do
      expect((FactoryGirl.create :act, :inherent_points => 5).points).to eq(5)
    end
  end

  context "for an act with no inherent points" do
    it "should return 0" do
      expect((FactoryGirl.create :act).points).to eq(0)
    end
  end
end
