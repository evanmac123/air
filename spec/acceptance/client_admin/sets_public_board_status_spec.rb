require 'acceptance/acceptance_helper'

feature "Client admin sets board's public status themself" do
  let (:client_admin) { FactoryGirl.create(:client_admin) }
  
  before do
    $rollout.activate_user(:public_board, client_admin.demo)
  end

  def click_make_board_public
    click_link "Make Public"
  end

  def click_make_board_private
    click_link "Make Private"
  end

  def expect_public_message
    expect_content "This board is currently public. Users can try the board and join it by going to:"
  end

  def expect_not_public_message
    expect_content "This board is not currently public."
  end

  def share_url_regex(slug)
    expected_path = public_board_path(public_slug: slug)
    %r"http://(127.0.0.1:\d+|www.example.com)#{expected_path}"
  end

  def expect_displayed_share_url(slug)
    page.body.should match(share_url_regex(slug))
  end

  context "when no slug is set" do
    before do
      client_admin.demo.public_slug.should be_nil
      visit client_admin_share_path(as: client_admin)
    end

    it "should tell the user the board's not public" do
      expect_not_public_message
    end

    it "should allow the client admin to set it", js: true do
      click_make_board_public
      expect_public_message
      expect_displayed_share_url(client_admin.demo.reload.public_slug)
    end
  end

  context "when a slug is already set" do
    before do
      client_admin.demo.update_attributes(public_slug: 'heyfriend')
      visit client_admin_share_path(as: client_admin)
    end

    it "should show the URL" do
      expect_displayed_share_url('heyfriend')
    end

    it "should allow the client admin to switch it off", js: true do
      click_make_board_private
      expect_not_public_message
    end

    it "should allow the client admin to change it"
    it "should have a handy copy-to-clipboard doohickey"
  end
end
