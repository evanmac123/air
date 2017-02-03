require 'acceptance/acceptance_helper'

feature 'Creates organization', js: true do
  describe "with defaults" do
    it "brings salesperson to Explore with helpful flash" do
      FactoryGirl.create(:demo, name: "HR Bulletin Board")
      admin = an_admin

      visit new_admin_sales_organization_path(as: admin)

      fill_in "organization[name]", with: "New Org"
      fill_in "organization[users_attributes][0][name]", with: "New User"
      fill_in "organization[users_attributes][0][email]", with: "new_user@airbo.com"

      click_button "Submit"

      expect(page).to have_content(User.last.invitation_code)
      expect(current_path).to eq(explore_path)
    end
  end
end
