require 'acceptance/acceptance_helper'

feature 'User must have authorization to see admin pages' do
  context "as a site admin" do
    before do
      signin_as_admin
    end

    it "can go to client admin pages" do
      visit client_admin_path
      should_be_on client_admin_path
    end

    it "can go to site admin pages" do
      visit admin_path
      should_be_on admin_path
    end

    it "has a nav link to client admin pages" do
      click_link 'Admin'
      should_be_on client_admin_path
    end

    it "has a nav link to site admin pages" do
      click_link "Site admin"
      should_be_on admin_path
    end
  end

  context "as a client admin" do
    before do
      signin_as_client_admin
    end

    it "can go to client admin pages" do
      visit client_admin_path
      should_be_on client_admin_path
    end

    it "can't go to site admin pages" do
      visit admin_path
      should_be_on activity_path
    end

    it "has a nav link to client admin pages" do
      click_link "Admin"
      should_be_on client_admin_path
    end

    it "has no nav link to site admin pages" do
      expect_no_content 'Site admin'
    end
  end

  context "as an ordinary schmuck" do
    before do
      user = FactoryGirl.create(:user)
      has_password user, 'foobar'
      signin_as user, 'foobar'
    end

    it "can't go to client admin pages" do
      visit client_admin_path
      should_be_on activity_path
    end

    it "can't go to site admin pages" do
      visit admin_path
      should_be_on activity_path
    end

    it "has no nav link to client admin pages" do
      expect_no_content "Admin"
    end

    it "has no nav link to site admin pages" do
      expect_no_content 'Site admin'
    end
  end
end
