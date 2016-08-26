require 'spec_helper'

describe LeadContactApproval do
  describe "LeadContact approval" do
    before do
      @lead_contact = FactoryGirl.create(:lead_contact, status: "pending")
    end
  end
end
