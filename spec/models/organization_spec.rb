require 'spec_helper'

describe Organization do
  it "is valid when complete" do
    o = FactoryGirl.build(:organization)
    expect(o.valid?).to be_true
  end

  context "created org" do

    let(:org){FactoryGirl.create(:organization, :with_contracts)}

    describe "customer_start_date" do

      it "has start_date equal to earliest contract start date" do
        expect(org.customer_start_date.to_s).to eq("2012-01-01")
      end

      it "has start_date equal to earliest contract start date" do
        expect(org.customer_end_date.to_s).to eq("2014-12-31")
      end

    end

    describe "active" do
      it "is true if customer_end_date is greater than today" do
        new_today = Date.parse('2014-10-30')
        Timecop.freeze(new_today) do
          expect(org.active).to  be_true
        end
      end

      it "is false if customer_end_date is greater than today" do
        new_today = Date.parse('2018-10-30')
        Timecop.freeze(new_today) do
          expect(org.active).to  be_false
        end
      end
    end

    describe "life_time" do
      it "equals totalmonths of contracts" do
        expect(org.life_time).to  eq 36 
      end
    end


  end
end
