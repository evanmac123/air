require 'acceptance/acceptance_helper'

feature "Client admin sets board's public status themself" do
  let (:client_admin) { FactoryGirl.create(:client_admin) }
    
  before do
    client_admin.demo.update_attributes(public_slug: 'heyfriend')
    tile = FactoryGirl.create :tile, demo: client_admin.demo
    user = FactoryGirl.create :user, demo: client_admin.demo
    FactoryGirl.create(:tile_completion, tile: tile, user: user)      
  end

  def click_on_link
    page.find('#on_toggle').click
  end

  def click_off_link
    page.find('#off_toggle').click
  end

  def share_url_regex(slug)
    expected_path = public_board_path(public_slug: slug)
    %r"http://(127.0.0.1:\d+|www.example.com)#{expected_path}"
  end

  def expect_displayed_share_url(slug)
    page.body.should match(share_url_regex(slug))
  end

  def expect_on_engaged
    page.all('#on_toggle.engaged').should be_present
    page.all('#off_toggle.engaged').should be_empty
  end

  def expect_off_engaged
    page.all('#on_toggle.engaged').should be_empty
    page.all('#off_toggle.engaged').should be_present
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
      expect_off_engaged
    end
  end
end
