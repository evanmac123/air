require 'acceptance/acceptance_helper'

feature 'Sees when users were last uploaded' do
  before do
    @client_admin = FactoryBot.create(:client_admin)
    @demo = @client_admin.demo
    FactoryBot.create(:tile, status: Tile::ACTIVE, demo: @demo) # unlock the users page
  end

  context "when they never actually were" do
    before do
      expect(@demo.users_last_loaded).to be_nil
    end

    it "shows something appropriate" do
      visit client_admin_users_path(as: @client_admin)
      expect(page).to have_no_content("Last added users")
    end
  end

  context "when they were at some point" do
    before do
      @demo.update_attributes(users_last_loaded: Chronic.parse("May 1, 2012, 12:00 PM"))
    end

    it "shows the date" do
      visit client_admin_users_path(as: @client_admin)
      expect(page).to have_content("Last added users on May 1, 2012")
    end
  end
end
