require 'acceptance/acceptance_helper'

feature 'Visits marketing page' do
  def expect_marketing_blurb
    expect_content "Get Their Attention HR and Corporate Communications use Airbo to modernize employee communcations."
  end

  context "as not user" do
    before(:each) do
      visit marketing_page
    end
    scenario "and see page" do
      expect_marketing_blurb
    end
  end

  context "as User" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      visit activity_path(as: @user)
      click_link "Sign Out"
      visit marketing_page
    end

    scenario "and see page" do
      expect_marketing_blurb
    end
  end

  context "as Guest User" do
    before(:each) do
      @public_demo = FactoryGirl.create(:demo, :with_public_slug)
      visit public_board_path(@public_demo.public_slug)
      visit marketing_page
    end

    scenario "and see page" do
      expect_marketing_blurb
    end
  end
end
