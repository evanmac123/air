require 'spec_helper'

describe LeadContactApproval do
  describe "LeadContact approval" do
    before do
      @lead_contact = FactoryGirl.create(:lead_contact, status: "pending")

      @routing_attributes_new_org = { new_organization: "1" }
    end
  end
end
