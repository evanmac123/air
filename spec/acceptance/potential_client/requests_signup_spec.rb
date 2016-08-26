require 'acceptance/acceptance_helper'

feature "Potential user requests signup" do
  context 'As a potential client' do
    context "when I visit the marketing page and request a signup" do
      it "should send an email to sales notifying a signup request" do
        visit marketing_page

        fill_in("Enter your work email", with: "test@example.com", match: :first)
        click_button("Sign Up", match: :first)

        fill_in('lead_contact[name]', with: "Test Name")
        fill_in('lead_contact[company]', with: "Test Company")
        fill_in('lead_contact[phone]', with: "9018484848")

        click_button("Submit")

        expect_content("Someone from our team will reach out to you in the next 24 hours to get you set up.")
      end
    end
  end
end
