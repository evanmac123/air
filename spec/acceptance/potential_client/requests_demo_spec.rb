require 'acceptance/acceptance_helper'

feature "Potential user requests demo" do
  context 'As a potential client' do
    context "when I visit the marketing page and request a demo" do
      it "should send an email to sales notifying a demo request" do
        visit root_path

        click_link("Schedule a Demo", match: :first)

        fill_in('request[name]', with: "Test Name")
        fill_in('request[email]', with: "test@example.com")
        fill_in('request[company]', with: "Test Company")
        fill_in('request[phone]', with: "9018484848")

        click_button("Request demo")

        expect_content("Thanks for requesting a demo! We’ll email you within the next few hours to schedule a 30 minute overview.")
      end
    end
  end
end
