require 'acceptance/acceptance_helper'
feature "LeadContacts", js: true do
  context "An SDR takes a lead contact from pending to processed" do
    it "should create an organization, user and cloned board for lead contact" do
      admin = FactoryBot.create(:site_admin)
      lead_contact = FactoryBot.create(:lead_contact, organization_name: "Lead")
      campaign_demo = FactoryBot.create(:demo, name: "airbo.com Board", public_slug: "internal-validation")

      Campaign.create(name:"test", demo: campaign_demo)

      FactoryBot.create(:tile, demo: campaign_demo)

      visit admin_sales_lead_contacts_path(as: admin)

      expect(page).to have_content(lead_contact.name)
      expect(page).to have_content(lead_contact.organization)

      click_link "review"

      check "lead_contact_new_organization"

      click_button "Approve"

      within ".approved-leads" do
        expect(page).to have_content(lead_contact.name)
        click_link "build board"
      end

      find(".topic_cell", match: :first).click

      within ".lead-board-details" do
        template_field  = field_labeled("board[template]", disabled: true)
        expect(template_field.value).to eq("airbo.com Board")
      end

      click_button "Create Board"

      within ".processed-leads" do
        expect(page).to have_content(lead_contact.name)
      end
    end
  end
end
