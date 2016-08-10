require 'acceptance/acceptance_helper'

#NOTE These tests are no longer valid as 05/2016 and introduction of Content Library new users are no directed to the content libary instead of Explore
#TODO delete this feature spec

feature 'Explore Intro', js: true do#, driver: :selenium do
  pending "first sign in" do

    # let!(:client_admin) { FactoryGirl.create(:client_admin) }
    before do
      sign_up
    end
    it "should redirect to explore page" do
      expect_content "Tile Subjects"
      should_be_on client_admin_explore_path
    end

    it "should show explore modal" do
      within active_slide_sel do
        expect_content "Next"
      end
    end

    it "should show right text" do
      within active_slide_sel do
        expect_content "Welcome to Airbo! Just a quick word about how this works..."
        click_link "Next"

        expect_content "Tile Save time by finding beautiful, bite-sized content that your employees will see and love."
        click_link "Next"

        expect_content "Board Organize and share tiles as easily as sending an email."
        click_link "Next"

        expect_content "Explore Ready to find some amazing content?"
        click_link "Close and Explore"
      end
      expect(page).to have_selector(active_slide_sel, visible: false)
    end

    it "should not show modal after refresh" do
      expect(page).to have_selector(active_slide_sel, visible: true)
      visit current_path
      expect(page).to_not have_selector(active_slide_sel)
    end
  end

  pending "by link from explore email" do
    let(:admin)   { FactoryGirl.create :client_admin, :with_explore_intro, name: 'Robbie Williams', email: 'robbie@williams.com' }
    let(:tile) { FactoryGirl.create :multiple_choice_tile, :public, headline: 'Phil Kills Kittens', supporting_content: '6 kittens were killed' }

    before do
      visit explore_tile_preview_path(tile, explore_token: admin.explore_token)
    end

    it "sould show tile" do
      expect_content 'Phil Kills Kittens'
    end

    it "should show explore modal" do
      within active_slide_sel do
        expect_content "Next"
      end
    end

    it "should show right text" do
      within active_slide_sel do
        expect_content "Hello! Welcome to Airbo, where you can find engaging content like"
        click_link "Next"

        expect_content "Tile Save time by finding beautiful, bite-sized content that your employees will see and love."
        click_link "Next"
        expect_content "Board Organize and share tiles as easily as sending an email."
        click_link "Next"
        expect_content "Explore Ready to find some amazing content?"
        click_link "Close and Explore"
      end
      expect(page).to have_selector(active_slide_sel, visible: false)
    end

    it "should skip" do
      within active_slide_sel do
        expect_content "Hello! Welcome to Airbo, where you can find engaging content like"
        click_link "Skip"
      end
      expect(page).to have_selector(active_slide_sel, visible: false)
    end

    it "should navigate by dots" do
      within active_slide_sel do
        expect_content "Hello! Welcome to Airbo, where you can find engaging content like"
      end
      within ".slick-dots" do
        click_button "3"
      end
      within active_slide_sel do
        expect_content "Board Organize and share tiles as easily as sending an email."
      end
    end

    it "should not show modal after refresh" do
      expect(page).to have_selector(active_slide_sel, visible: true)
      visit current_path
      expect(page).to_not have_selector(active_slide_sel)
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

  def active_slide_sel
    ".explore_intro .slick-current"
  end
end
