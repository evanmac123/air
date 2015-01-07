require 'acceptance/acceptance_helper'

feature "Client admin sets board's public status themself" do
  let (:client_admin) { FactoryGirl.create(:client_admin) }
    
  before do
    client_admin.demo.update_attributes(public_slug: 'heyfriend')
    p client_admin.demo.public_slug
    tile = FactoryGirl.create :tile, demo: client_admin.demo
    user = FactoryGirl.create :user, demo: client_admin.demo
    FactoryGirl.create(:tile_completion, tile: tile, user: user)      
  end

  def click_on_link
    page.find('.switch').click
  end

  def click_off_link
    page.find('.switch').click
  end

  def share_url_regex(slug)
    expected_path = public_board_path(public_slug: slug)
    %r"http://(127.0.0.1:\d+|www.example.com)#{expected_path}"
  end

  def expect_displayed_share_url(slug)
    page.body.should match(share_url_regex(slug))
  end

  def expect_on_engaged
    page.find('#private_button')['checked'].should_not be_present
    page.find('#public_button')['checked'].should be_present
  end

  def expect_off_engaged
    page.find('#private_button')['checked'].should be_present
    page.find('#public_button')['checked'].should_not be_present
  end

  context "when the board is public" do
    before do
      client_admin.demo.is_public.should be_true
      visit client_admin_share_path(as: client_admin)
    end

    it "should tell the user the board's not private" do
      expect_on_engaged
    end

    it "should allow the client admin to set it private", js: true do
      click_off_link
      expect_off_engaged
    end

    it "should show the public slug regardless" do
      expect_displayed_share_url('heyfriend')
    end
    
    it "should display tooltip on mouseover question mark icon", js: true do
      page.find('.fa-question-circle').trigger(:mouseover)
      page.should have_content("If Private, only people you add can see your board. If public, anyone with the share link can see and join it.")
    end
    
    it "should have unlock icon with respective message" do
      page.should have_css('.fa-unlock')
      page.should have_content("SHARE LINK IS ACTIVE")
    end
  end

  context "when the board is already private" do
    before do
      client_admin.demo.update_attributes(is_public: false)
      visit client_admin_share_path(as: client_admin)
    end

    it "should show the URL" do
      expect_displayed_share_url('heyfriend')
    end

    it "should look switched on" do
      expect_off_engaged
    end

    it "should allow the client admin to switch it off", js: true do
      click_off_link
      expect_on_engaged
    end
    it "should have lock icon with respective message" do
      page.should have_css('.fa-lock')
      page.should have_content("SHARE LINK IS LOCKED")
    end
  end
end
