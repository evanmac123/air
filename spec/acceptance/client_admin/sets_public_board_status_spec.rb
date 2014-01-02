require 'acceptance/acceptance_helper'

feature "Client admin sets board's public status themself" do
  let (:client_admin) { FactoryGirl.create(:client_admin) }
  
  before do
    $rollout.activate_user(:public_board, client_admin.demo)
    client_admin.demo.update_attributes(public_slug: 'heyfriend')
  end

  def click_make_board_public
    click_link "Make Public"
  end

  def click_make_board_private
    click_link "Make Private"
  end

  def expect_public_message
    expect_content "This board is currently public. Send the link below to people you'd like to join."
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

  context "when the board is private" do
    before do
      client_admin.demo.is_public.should be_false
      visit client_admin_share_path(as: client_admin)
    end

    it "should tell the user the board's not public" do
      expect_not_public_message
    end

    it "should allow the client admin to set it public", js: true do
      click_make_board_public
      expect_public_message
      expect_displayed_share_url(client_admin.demo.reload.public_slug)
    end

    it "should show the public slug regardless" do
      expect_displayed_share_url('heyfriend')
    end
  end

  context "when the board is already public" do
    before do
      client_admin.demo.update_attributes(is_public: true)
      visit client_admin_share_path(as: client_admin)
    end

    it "should show the URL" do
      expect_displayed_share_url('heyfriend')
    end

    it "should allow the client admin to switch it off", js: true do
      click_make_board_private
      expect_not_public_message
    end

    it "should have a handy copy-to-clipboard doohickey"
  end
end
