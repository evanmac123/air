require 'acceptance/acceptance_helper'

feature 'User must have authorization to see admin pages' do
  context "as a site admin" do
    let(:admin) { FactoryBot.create :user, :is_site_admin => true }

    it "can go to client admin pages" do
      visit client_admin_reports_path(as: admin)
      should_be_on client_admin_reports_path
    end

    it "can go to site admin pages" do
      visit admin_path(as: admin)
      should_be_on admin_path
    end

    it "has a nav link to site admin pages" do
      visit root_path(as: admin)
      click_link "Site admin"
      should_be_on admin_path
    end
  end

  context "as a client admin" do
    let(:client_admin) { FactoryBot.create :user, :is_client_admin => true }

    it "can go to client admin pages" do
      visit client_admin_reports_path(as: client_admin)
      should_be_on client_admin_reports_path
    end

    it "can't go to site admin pages" do
      visit admin_path(as: client_admin)
      should_be_on explore_path
    end

    it "has no nav link to site admin pages" do
      visit root_path(as: client_admin)
      expect_no_content 'Site admin'
    end
  end

  context "as an ordinary schmuck" do
    let(:user) { FactoryBot.create(:user) }

    it "can't go to client admin pages" do
      visit client_admin_reports_path(as: user)
      should_be_on activity_path
    end

    it "can't go to site admin pages" do
      visit admin_path(as: user)
      should_be_on activity_path
    end

    it "has no nav link to client admin pages" do
      visit root_path(as: user)
      expect_no_content "Admin"
      expect_no_content 'Site admin'
    end
  end
end
