describe ContractRenewer do

   describe ".execute" do
    before do
       @expiring_today = FactoryGirl.create(:contract, :complete, start_date: 1.year.ago.to_date, end_date: Date.today)
       expiring_yesterda = FactoryGirl.create(:contract, :complete, start_date: 1.year.ago.to_date, end_date: Date.yesterday)
       expiring_today = FactoryGirl.create(:contract, :complete, start_date: Date.tomorrow, end_date: Date.tomorrow.advance(years:1))
       expiring_today = FactoryGirl.create(:contract, :complete, start_date: 3.months.ago.to_date, end_date: 9.months.from_now.to_date)
    end
     it "renews active renewable contracts expiring today" do
       expect{ContractRenewer.execute}.to change{Contract.count}.by 1
     end

   end


end
