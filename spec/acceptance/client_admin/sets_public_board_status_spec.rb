require 'acceptance/acceptance_helper'

feature "Client admin sets board's public status themself" do

#  it "should work as advertised" do
    #client_admin = FactoryGirl.create(:client_admin)
    #$rollout.activate_user(:public_board, client_admin.demo)
    #visit client_admin_share_path(as: client_admin)

    #debugger
    #pending
  #end

  let (:client_admin) { FactoryGirl.create(:client_admin) }
  
  before do
    $rollout.activate_user(:public_board, client_admin.demo)
  end

  def click_make_board_public
    click_link "Make Public"
  end

  def expect_not_public_message
    expect_content "This board is not currently public."
  end

  context "when no slug is set" do
    before do
      client_admin.demo.public_slug.should be_nil
      visit client_admin_share_path(as: client_admin)
    end

    it "should tell the user the board's not public" do
      expect_not_public_message
    end

    it "should not try to show a share URL"

    it "should allow the client admin to set it", js: true do
      click_make_board_public
      expect_displayed_share_url(client_admin.demo.reload.public_slug)
    end
  end

  context "when a slug is already set" do
    it "should allow the client admin to switch it off"
    it "should allow the client admin to change it"
    it "should have a handy copy-to-clipboard doohickey"
  end
end
