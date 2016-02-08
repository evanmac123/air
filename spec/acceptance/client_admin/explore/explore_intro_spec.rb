require 'acceptance/acceptance_helper'

feature 'Explore Intro', js: true do#, driver: :selenium do
  context "first sign in" do
    # let!(:client_admin) { FactoryGirl.create(:client_admin) }
    before do
      sign_up
    end
    it "should redirect to explore page" do
      expect_content "Tile Subjects"
      should_be_on client_admin_explore_path
    end

    it "souls show explore modal" do
      within active_slide do
        expect_content "Next"
      end
    end

    it "sould show right text" do
      within active_slide do
        expect_content "Welcome to Airbo! Just a quick word about how this works..."
        click_link "Next"
        expect_content "Tile Save time by finding beautiful, bite-sized content that your employees will see and love."
        click_link "Next"
        expect_content "Board Organize and share tiles as easily as sending an email."
        click_link "Next"
        expect_content "Explore Are you ready to find amazing content?!"
        click_link "Close and Explore"
      end
      find_active_slide.should_not be_present
    end

    it "should not show modal after refresh" do
      visit current_path
      find_active_slide.should_not be_present
    end
  end

  def sign_up
    visit product_path
    fill_in "user[name]", with: "Ali Baba"
    fill_in "user[email]", with: "ali@baba.com"
    fill_in "board[name]", with: "express"
    fill_in "user[password]", with: "password"
    click_button "Sign Up"
  end

  def active_slide
    page.find(".orbit-slides-container>li.active")
  end

  def find_active_slide
    page.all(".orbit-slides-container>li.active").first
  end
end