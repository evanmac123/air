require 'acceptance/acceptance_helper'
feature "LeadContacts", js: true do
  context "An SDR takes a lead contact from pending to processed" do
    it "should create an organization, user and cloned board for lead contact" do
      admin = FactoryGirl.create(:site_admin)
      lead_contact = FactoryGirl.create(:lead_contact, organization_name: "Lead")
      stock_board = FactoryGirl.create(:demo, name: "airbo.com Board", public_slug: "internal-validation")
      tile = FactoryGirl.create(:tile, demo: stock_board)
      Demo.stubs(:stock_boards).returns(Demo.where(name: stock_board.name))

      visit admin_sales_lead_contacts_path(as: admin)

      expect(page).to have_content(lead_contact.name)
      expect(page).to have_content(lead_contact.organization)

      click_link "review"

      check "lead_contact_new_organization"

      click_button "Approve"

      click_link "Continue"

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

      new_board_window = window_opened_by { click_link "customize board" }

      within_window new_board_window do
        expect(current_path).to eq("/client_admin/tiles")
        expect(page).to have_content(tile.headline)
      end

      send_digest_window = window_opened_by { click_link "send digest email" }

      within_window send_digest_window do
        expect(current_path).to eq("/client_admin/share")
      end
    end
  end
end
