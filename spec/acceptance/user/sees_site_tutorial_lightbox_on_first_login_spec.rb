require 'acceptance/acceptance_helper'

feature "The site tutorial" do
  let (:user) { FactoryGirl.create :user }

  def site_tutorial_lightbox_selector
    "#get_started_lightbox"
  end

  def site_tutorial_content
    "This is some helpful instructions about how to get started with H.Engage."
  end

  def expect_no_site_tutorial_lightbox
    page.all(site_tutorial_lightbox_selector).should be_empty
  end

  context 'on first login' do
    before do
      user.update_attributes(session_count: 1)
      visit activity_path(as: user)
    end

    scenario 'sees site tutorial lightbox and accompanying decoration around the sample tile', js: true do
      within(site_tutorial_lightbox_selector) { expect_content site_tutorial_content }
    end

    scenario "makes lightbox go away by clicking a link", js: true do
      within(site_tutorial_lightbox_selector) do
        click_link "Close"
        expect_no_site_tutorial_lightbox
      end
    end
  end

  context 'on subsequent logins' do
    before do
      user.update_attributes(session_count: 2)
      visit activity_path(as: user)
    end

    scenario 'sees no site tutorial lightbox', js: true do
      expect_no_site_tutorial_lightbox
      expect_no_content site_tutorial_content
    end

    scenario 'can summon site tutorial lightbox from the help page'
  end
end
