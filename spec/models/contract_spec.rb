require 'spec_helper'

describe Contract do
  it "is invalid without all required fields" do
   c = Contract.new
   expect(c.valid?).to be_false
 end

 it "is valid if all required fields provided" do
   c = FactoryGirl.build(:contract, :complete)
   expect(c.valid?).to be_true
 end

 it "is a valid upgrade if all fields provided and has valid parent" do
   c = FactoryGirl.build(:upgrade, :valid)
   expect(c.valid?).to be_true
 end

 pending "upgrade is invalid wthout parent contract " do
   c = FactoryGirl.build(:upgrade )
   expect(c.valid?).to be_false
 end
end
