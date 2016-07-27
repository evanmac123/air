require 'acceptance/acceptance_helper'

feature 'Resets upload in progress' do
  def upload_in_progress_message
    "Upload in progress..."
  end

  def reset_button_text
    "Reset upload-in-progress status"
  end

  scenario "by pushing a button" do
    board = FactoryGirl.create(:demo, upload_in_progress: true)
    visit admin_demo_path(board, as: an_admin)

    page.should have_content(upload_in_progress_message)
    click_button reset_button_text
    page.should have_no_content(upload_in_progress_message)
  end

  context "except that board isn't actually in progress" do
    it "should say so" do
      board = FactoryGirl.create(:demo)
      visit admin_demo_path(board, as: an_admin)

      page.should have_no_content(upload_in_progress_message)
      page.should have_no_content(reset_button_text)
    end
  end
end
