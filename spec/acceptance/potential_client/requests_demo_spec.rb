require 'acceptance/acceptance_helper'

feature "Potential user requests demo", js: true do
  context 'As a potential client' do
    context "when I visit the marketing page and request a demo" do
      it "should send an email to sales notifying a demo request" do
        visit new_demo_request_path
        page.has_css?('lead_contact[name]')

        fill_in('lead_contact[name]', with: "Test")
        fill_in('lead_contact[email]', with: "test@example.com")
        fill_in('lead_contact[organization_name]', with: "Test Company")
        fill_in('lead_contact[phone]', with: "9018484848")
        fill_in('lead_contact[name]', with: "Test Name")

        click_button("Submit")


        within ".airbo-marketing-site" do
          expect_content("Someone from our team will reach out to you in the next 24 hours to schedule a time to chat.")
        end
      end
    end
  end
end
