require 'acceptance/acceptance_helper'

feature 'Client admin sees basic stats on dashboard' do
  context "with a small number of users" do
    before do
      demo = signin_as_client_admin.demo
      @users = FactoryGirl.create_list(:user, 5, :claimed, demo: demo)
      FactoryGirl.create_list(:user,  5, demo: demo)
      FactoryGirl.create_list(:site_admin,  2, demo: demo)
      FactoryGirl.create(:tile, demo: demo)

      User.claimed.each { |user|
        user.current_board_membership.update_attributes(joined_board_at: Time.now)
      }
    end

    it "should include the number of claimed users" do
      #TODO complete this test spec with more assertions about the page
      visit client_admin_path
      within ".total-users" do
        expect_content "5 Employees Activated"
      end

      within ".tiles-posted" do
        expect_content "1 Tiles posted"
      end
    end

  end
end
