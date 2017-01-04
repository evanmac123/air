describe ContractRenewer do
 before do

 end
  it "selects renewable contracts only" do
    end_date = 5.days.from_now
    start_date = end_date.advance(years: -1) 
    end_date2 = 8.days.from_now
    start_date2 = end_date2.advance(months: -1)


    FactoryGirl.create(:contract, :complete, cycle: Contract::ANNUAL, start_date: 120.days.ago, end_date: Date.yesterday)
    FactoryGirl.create(:contract, :complete, cycle: Contract::ANNUAL, start_date: start_date, end_date: end_date)
    FactoryGirl.create(:contract, :complete, cycle: Contract::MONTHLY, renewed_on: Date.yesterday,  start_date: start_date, end_date: end_date)
    FactoryGirl.create(:contract, :complete, cycle: Contract::MONTHLY, start_date: start_date2, end_date: end_date2)
    expect{ContractRenewer.execute}.to change{Contract.count}.by 1
  end




end
