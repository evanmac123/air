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

    describe "update" do
      it "updates the LeadContact attributes" do
        @attributes["name"] = "New Name"
        @attributes["phone"] = ""
        @attributes["matched_organization"] = "Existing Org"

        LeadContactUpdater.new(@attributes, "Deny").update

        lead_contact = LeadContact.find(@lead_contact.id)

        expect(lead_contact.name).to eq("New Name")
        expect(lead_contact.phone).to eq("invalid")
        expect(lead_contact.organization_name).to eq("Existing Org")
      end
    end
  end
end
