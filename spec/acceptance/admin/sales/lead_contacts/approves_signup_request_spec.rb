require 'acceptance/acceptance_helper'

feature 'Admin aproves a signup request', js: true do
  describe "with matched organization" do
    it "changes lead contact status to denied and updates organization" do
      organization = FactoryGirl.create(:organization, name: "Client")
      lead_contact = FactoryGirl.create(:lead_contact, organization_name: "Fake Client")
      admin = an_admin

      visit admin_sales_lead_contacts_path(as: admin)

      click_link "start"

      fill_in "search existing organizations", with: organization.name.first

      click_button "Search"

      click_button organization.name

      click_button "Approve"

      within "div.pending-leads" do
        expect(page).to_not have_content(lead_contact.name)
      end

      within "div.approved-leads" do
        expect(page).to have_content(lead_contact.name)
        expect(page).to have_content("Client")
        expect(page).to_not have_content("Fake Client")
      end
    end
  end

  describe "with new organization" do
    it "changes lead contact status to denied and updates organization" do
      lead_contact = FactoryGirl.create(:lead_contact, organization_name: "Fake Client")

      admin = an_admin

      visit admin_sales_lead_contacts_path(as: admin)

      click_link "start"

      find(:css, "#lead_contact_new_organization").set(true)

      fill_in "Organization", with: "Client"

      click_button "Approve"

      within "div.pending-leads" do
        expect(page).to_not have_content(lead_contact.name)
      end

      within "div.approved-leads" do
        expect(page).to have_content(lead_contact.name)
        expect(page).to have_content("Client")
        expect(page).to_not have_content("Fake Client")
      end
    end
  end
end
