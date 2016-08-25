require 'spec_helper'

describe LeadContactUpdater do
  describe "LeadContact evaluation" do
    before do
      @lead_contact = FactoryGirl.create(:lead_contact, status: "pending")

      @attributes = {
        "name"=>"Name",
        "email"=>"email@airbo.com",
        "phone"=>"4340004444",
        "organization_name"=>"Org Name",
        "id"=>@lead_contact.id.to_s
      }

      @attributes_for_new_organization = @attributes.merge(
        "organization_size" => "less than 100 employees",
        "new_organization" => "1"
      )

      @attributes_for_existing_organization = @attributes.merge(
        "matched_organization" => "Existing Org"
      )
    end

    describe "denial" do
      it "updates the LeadContact attributes and cahnges status to denied" do
        @attributes["phone"] = ""
        @attributes["name"] = "New Name"

        LeadContactUpdater.update(@attributes, "Deny")

        lead_contact = LeadContact.find(@lead_contact.id)

        expect(lead_contact.status).to eq("denied")
        expect(lead_contact.name).to eq("New Name")
        expect(lead_contact.phone).to eq("")
      end
    end
  end
end
