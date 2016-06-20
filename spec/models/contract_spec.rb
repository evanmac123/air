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
    c = FactoryGirl.build(:upgrade, :with_parent)
    expect(c.role_type).to eq "Upgrade"
  end

  it "is an invalid upgrade wthout parent contract " do
    c = FactoryGirl.build(:upgrade )
    expect(c.role_type).to eq "Primary"
  end

  it "is an invalid if custom without term " do
    c = FactoryGirl.build(:contract, :complete, :custom )
    expect(c.valid?).to be_false
  end

  it "is an valid if custom without term " do
    c = FactoryGirl.build(:contract, :complete, :custom_valid )
    expect(c.valid?).to be_true
  end

  describe "renew" do
    context "first and last day of month" do
      it "sets proper start and end for annaul contracts" do
        sdate = Date.new(2014,1,1)
        edate = Date.new(2014,12,31)
        c = FactoryGirl.build(:contract, :complete, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2015,1,1)
        expect(d.end_date).to eq Date.new(2015,12,31)
      end 

      it "sets proper start and end for semi-annaul contracts" do
        sdate = Date.new(2014,1,1)
        edate = Date.new(2014,6,30)
        c = FactoryGirl.build(:contract, :complete, cycle: Contract::SEMI_ANNUAL, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2014,7,1)
        expect(d.end_date).to eq Date.new(2014,12,31)
      end 

      it "sets proper start and end for quarterly contracts" do
        sdate = Date.new(2014,1,1)
        edate = Date.new(2014,3,31)
        c = FactoryGirl.build(:contract, :complete, cycle: Contract::QUARTERLY, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2014,4,1)
        expect(d.end_date).to eq Date.new(2014,6,30)
      end 

      it "sets proper start and end for monthly contracts" do
        sdate = Date.new(2014,2,1)
        edate = Date.new(2014,2,28)
        c = FactoryGirl.build(:contract, :complete, cycle: Contract::MONTHLY, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2014,3,1)
        expect(d.end_date).to eq Date.new(2014,3,31)
      end 

      it "sets proper start and end for custom contracts" do
        sdate = Date.new(2014,2,1)
        edate = Date.new(2014,5,31)
        c = FactoryGirl.build(:contract, :complete, cycle: Contract::CUSTOM, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2014,6,1)
        expect(d.end_date).to eq Date.new(2014,8,31)
      end 
    end

    context "random  days and  month" do
      it "sets proper start and end for annaul contracts" do
        sdate = Date.new(2014,1,18)
        edate = Date.new(2015,1,17)
        c = FactoryGirl.build(:contract, :complete, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2015,1,18)
        expect(d.end_date).to eq Date.new(2016,1,17)
      end 

      it "sets proper start and end for semi-annaul contracts" do
        sdate = Date.new(2014,1,17)
        edate = Date.new(2014,7,16)
        c = FactoryGirl.build(:contract, :complete, cycle: Contract::SEMI_ANNUAL, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2014,7,17)
        expect(d.end_date).to eq Date.new(2015,1,16)
      end 

      it "sets proper start and end for monthly contracts" do
        sdate = Date.new(2014,3,13)
        edate = Date.new(2014,4,12)
        c = FactoryGirl.build(:contract, :complete, cycle: Contract::MONTHLY, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2014,4,13)
        expect(d.end_date).to eq Date.new(2014,5,12)
      end 


     
      it "sets proper start and end for custom contracts" do
        sdate = Date.new(2014,2,1)
        edate = Date.new(2014,5,31)
        c = FactoryGirl.build(:contract, :complete, cycle: Contract::CUSTOM, start_date: sdate, end_date: edate)
        d = c.renew
        expect(d.start_date).to eq Date.new(2014,6,1)
        expect(d.end_date).to eq Date.new(2014,8,31)
      end 
    end


    
  end
end
