require 'acceptance/acceptance_helper'

feature 'Client admin sees basic stats on dashboard' do
  context "with a small number of users" do
    before do
      @demo = signin_as_client_admin.demo
      10.times {FactoryGirl.create :user, :claimed, demo: @demo}
      5.times { FactoryGirl.create :tile, demo: @demo }
    end

    it "should include the number of users for the board" do
      visit client_admin_path
      within "div.total-users" do
        expect_content "10 users joined"
      end
    end

    it "should include the number of tiles posted for the board" do
      visit client_admin_path
      within "div.total-tiles" do
        expect_content "5 tiles posted"
      end
    end

    it "should include the number of actions taken for the board" do
      7.times { User.first.acts.create(demo_id: @demo.id) }
      visit client_admin_path
      within "div.total-actions" do
        expect_content "7 actions taken"
      end
    end
  end
end
