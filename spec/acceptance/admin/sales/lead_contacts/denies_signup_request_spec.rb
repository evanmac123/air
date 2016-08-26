require 'acceptance/acceptance_helper'

feature 'Admin denies a signup request' do
  it "changes lead contact status to denied and sends email to lead contact" do
    lead_contact = FactoryGirl.create(:lead_contact)
    admin = an_admin

    visit admin_sales_lead_contacts_path(as: admin)

    within "tr##{lead_contact.id}" do
      click_link "start"
    end

    click_button "Deny"

    within "div.pending-leads" do
      expect(page).to_not have_content(lead_contact.name)
    end
  end
end
