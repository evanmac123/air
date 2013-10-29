require 'acceptance/acceptance_helper'

feature "The site tutorial" do
  let (:user) { FactoryGirl.create :user }

  def site_tutorial_lightbox_selector
    "#get_started_lightbox"
  end

  def site_tutorial_content
    "Welcome to H.Engage! Read and answer the questions on tiles for points. To get started, click on the first tile below."
  end

  def expect_no_site_tutorial_lightbox
    page.all(site_tutorial_lightbox_selector).should be_empty
  end

  context 'on first login' do
    before do
      user.update_attributes(session_count: 1)
    end

    context "when there's at least one active tile in the demo" do
      before do
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: user.demo)
        visit activity_path(as: user)
      end

      scenario 'sees site tutorial lightbox and accompanying decoration around the sample tile', js: true do
        within(site_tutorial_lightbox_selector) { expect_content site_tutorial_content }
      end

      scenario "makes lightbox go away by clicking a link, and doesn't see it again on going away and returning to activity page", js: true do
        within(site_tutorial_lightbox_selector) do
          click_link "Close"
          expect_no_site_tutorial_lightbox
        end

        visit activity_path
        expect_no_site_tutorial_lightbox
      end
    end

    context "if there are no active tiles" do
      before do
        FactoryGirl.create(:tile, status: Tile::ARCHIVE, demo: user.demo)
        user.demo.tiles.active.should be_empty
        visit activity_path(as: user)
      end

      it "should show no tutorial content" do
        expect_no_site_tutorial_lightbox
        expect_no_content(site_tutorial_content)
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
  end
end
