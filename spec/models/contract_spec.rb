require 'spec_helper'

describe Contract do
  it "is valid if all required fields provided" do
    c = FactoryGirl.build(:contract, :complete)
    expect(c.valid?).to be_truthy
  end

  it "is a valid upgrade if all fields provided and has valid parent" do
    c = FactoryGirl.build(:upgrade, :with_parent)
    expect(c.role_type).to eq "Upgrade"
  end

  it "is invalid upgrade wthout parent contract " do
    c = FactoryGirl.build(:upgrade )
    expect(c.role_type).to eq "Primary"
  end

  it "is invalid if custom without term " do
    c = FactoryGirl.build(:contract, :complete, :custom )
    expect(c.valid?).to be_falsey
  end

  it "is invalid if arr is not annualized mrr " do
    c = FactoryGirl.create(:contract, :complete, mrr:100 )
    c.update_attribute(:arr, 1000)
    c.max_users = 666
    expect(c.save).to be_falsey
  end

  it "is valid when arr is annualized mrr " do
    a = FactoryGirl.build(:contract, :complete, arr:9345, mrr:779 )
    b = FactoryGirl.build(:contract, :complete, arr:425, mrr:35 )
    c = FactoryGirl.build(:contract, :complete, arr:2438, mrr:203 )
    d = FactoryGirl.build(:contract, :complete, arr:594, mrr:50 )
    e = FactoryGirl.build(:contract, :complete, arr:1650, mrr:138 )
    expect(a.valid?).to be_truthy
    expect(b.valid?).to be_truthy
    expect(c.valid?).to be_truthy
    expect(d.valid?).to be_truthy
    expect(e.valid?).to be_truthy
  end

  it "is valid if custom without term " do
    c = FactoryGirl.build(:contract, :complete, :custom_valid )
    expect(c.valid?).to be_truthy
  end

  it "it should always set mrr if arr is set explicitly" do
    c = FactoryGirl.create(:contract,:complete, :custom_valid, mrr: nil )
    expect(c.mrr).to_not be_nil
  end

  it "it should always set arr if mrr is set explicitly" do
    c = FactoryGirl.create(:contract,:complete, :custom_valid, mrr: 1000, arr: nil )
    expect(c.arr).to_not be_nil
  end

  it "it does not update mrr or arr unless either changes  " do
    c = FactoryGirl.create(:contract, :complete, :custom_valid )
    c.name = "renamed"
    c.start_date = 1.year.ago
    c.end_date = Date.yesterday
    c.name = "Herby"
    c.expects(:mrr=).never
    c.expects(:arr=).never
    c.save
  end

  it "it changes mrr if arr changes" do
    c = FactoryGirl.create(:contract, :complete, :custom_valid )
    expect{c.arr=12000;c.save}.to change{c.mrr}
  end

  it "it changes arr if mrr changes" do
    c = FactoryGirl.create(:contract, :complete, :custom_valid, arr:nil, mrr:1000 )
    expect{c.mrr=500;c.save}.to change{c.arr}
  end

  describe "renew" do

    it "sets the renewal date on the current contract" do
      sdate = Date.new(2014,1,1)
      edate = Date.new(2014,12,31)
      c = FactoryGirl.build(:contract, :complete, start_date: sdate, end_date: edate)
      c.renew
      expect(c.renewed_on).to eq Date.today
    end

    it "does not set the renewed on date for the new contract" do
      sdate = Date.new(2014,1,1)
      edate = Date.new(2014,12,31)
      c = FactoryGirl.build(:contract, :complete, start_date: sdate, end_date: edate)
      d = c.renew
      expect(d.renewed_on).to be_nil
    end


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
        expect(d.end_date).to eq Date.new(2014,9,30)
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
        expect(d.end_date).to eq Date.new(2014,9,30)
      end
    end



  end
end
