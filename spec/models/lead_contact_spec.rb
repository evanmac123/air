require 'spec_helper'

describe LeadContact do
  it { should belong_to :user }

  it { should validate_presence_of :name}
  it { should validate_presence_of :email}
  it { should validate_presence_of :phone}

  it "parses phone number correctly before create" do
    lead_contact = FactoryGirl.create(:lead_contact, phone: "999-394-3940", status: "")

    expect(lead_contact.phone).to eq("9993943940")
    expect(lead_contact.status).to eq("pending")
  end
end
