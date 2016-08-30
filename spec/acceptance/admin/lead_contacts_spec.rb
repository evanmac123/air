require 'acceptance/acceptance_helper'
feature "LeadContacts", js: true do
  context "An SDR takes a lead contact from pending to processed" do
    it "should create an organization, user and cloned board for lead contact" do
      admin = FactoryGirl.create(:site_admin)
      lead_contact = FactoryGirl.create(:lead_contact, organization_name: "Lead")

      visit admin_sales_lead_contacts_path(as: admin)

      expect(page).to have_content(lead_contact.name)
      expect(page).to have_content(lead_contact.organization)

      click_link "review"

      check ""
    end
  end
end
