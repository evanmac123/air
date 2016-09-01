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

      @board_params = {}
    end

    describe "update" do
      it "updates the LeadContact attributes" do
        @attributes["name"] = "New Name"
        @attributes["phone"] = ""
        @attributes["matched_organization"] = "Existing Org"

        LeadContactUpdater.new(@attributes, {}, "Deny").update

        lead_contact = LeadContact.find(@lead_contact.id)

        expect(lead_contact.name).to eq("New Name")
        expect(lead_contact.phone).to eq("invalid")
        expect(lead_contact.organization_name).to eq("Existing Org")
      end
    end

    describe "dispatches to deny" do
      it "changes the status to denied" do
        LeadContactUpdater.new(@attributes, {}, "Deny").dispatch

        lead_contact = LeadContact.find(@lead_contact.id)

        expect(lead_contact.status).to eq("denied")
      end

      it "send an email to the LeadContact" do
        LeadContactUpdater.new(@attributes, {}, "Deny").dispatch

        open_email @lead_contact.email

        current_email.subject.should include(
          'Thanks for reaching out to Airbo!'
        )

        current_email.body.should include(
         "Hello - Thank you so much for your interest in Airbo! At this time, we only provide accounts to HR professionals, but if you have any questions or would like to chat with an Account Executive, please feel free to reply to this email, and we'd be happy to connect."
        )
      end
    end

    describe "dispatches to approve" do
      describe "the LeadContact with a new organization" do
        it "should create a new organization" do
          expect(Organization.count).to eq(0)

          LeadContactUpdater.new(@attributes_for_new_organization, {},  "Approve").dispatch

          expect(Organization.count).to eq(1)
        end

        it "should add an organization as a reference to the LeadContact" do
          LeadContactUpdater.new(@attributes_for_new_organization, {},  "Approve").dispatch

          expect(LeadContact.first.organization).to eq(Organization.first)
        end

        it "should change the LeadContact status to approved" do
          LeadContactUpdater.new(@attributes_for_new_organization, {},  "Approve").dispatch

          expect(LeadContact.first.status).to eq("approved")
        end
      end
    end
  end
end
