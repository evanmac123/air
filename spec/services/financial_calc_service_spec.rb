describe FinancialsCalcService do

  before do
    org1 = FactoryGirl.create(:organization)
    org2 = FactoryGirl.create(:organization)
    org3 = FactoryGirl.create(:organization)
    FactoryGirl.create(:contract, :complete, :active, organization: org1, date_booked: Date.today, start_date: 1.week.from_now, end_date: 53.weeks.from_now)
    FactoryGirl.create(:contract, :complete, :active, organization: org2, start_date: 3.months.ago, end_date: 9.months.from_now)
    FactoryGirl.create(:contract, :complete, :active, organization: org3, amt_booked: 100, mrr: 100, arr: 1200, cycle: Contract::MONTHLY, start_date: 3.months.ago, end_date: 1.month.from_now)


    @calc =FinancialsCalcService.new(Date.today, 1.week.from_now.to_date)
  end


  describe "#starting_customer_count" do
    it "behaves correctly" do
      expect(@calc.starting_customer_count).to eq(3)
    end
  end

  describe "#current_customer_count" do
    it "behaves correctly" do
      expect(@calc.current_customer_count).to eq(3)
    end
  end

  describe "#added_customer_amt_booked" do
    it "behaves correctly" do
      expect(@calc.added_customer_amt_booked).to eq(60000)
    end
  end


end
