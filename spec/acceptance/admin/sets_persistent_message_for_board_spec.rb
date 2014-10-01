require 'acceptance/acceptance_helper'

feature 'Admin sets persistent message for board' do
  def fill_in_persistent_message(message)
    fill_in "demo[persistent_message]", with: message
  end

  scenario "in the basic settings" do
    board = FactoryGirl.create(:demo)
    visit edit_admin_demo_path(board, as: an_admin)

    message = "This is the funnest possible thing"
    fill_in_persistent_message(message)
    click_button "Update Game"

    board.reload.persistent_message.should == message
  end
end
