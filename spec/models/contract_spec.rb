require 'spec_helper'

describe Contract do
  it "is invalid without all required fields" do
   c = Contract.new
   expect(c.save).to be_false
 end

  it "is valid with required fields" do
   org = Organization.create({name: "Omni Corp"})
   c = Contract.new
   c.organization = org 

   c.name = "Con Tract"
   c.start_date = Date.today 
   c.end_date = 1.year.from_now 
   c.arr = 60000

   c.term = 12
   c.estimate_type = "Con Tract"
   c.rank = "primary"
   c.plan = Contract.plan_name_for :engage
   c.max_users = 100
   expect(c.save).to be_true
 end

end
