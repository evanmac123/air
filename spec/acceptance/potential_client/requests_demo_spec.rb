require 'acceptance/acceptance_helper'

feature "Potential user requests demo", js: true do
  context 'As a potential client' do
    context "when I visit the marketing page and request a demo" do
      it "should send an email to sales notifying a demo request" do
        visit root_path

        click_link("Schedule a Demo", match: :first)

        fill_in('request[name]', with: "Test")
        fill_in('request[email]', with: "test@example.com")
        fill_in('request[company]', with: "Test Company")
        fill_in('request[phone]', with: "9018484848")

        click_button("Request demo")

        expect_content("Please enter your first and last name.")

        fill_in('request[name]', with: "Test Name")

        click_button("Request demo")

        expect_content("Someone from our team will reach out to you in the next 24 hours to schedule a time to chat.")
      end
    end
  end
end
