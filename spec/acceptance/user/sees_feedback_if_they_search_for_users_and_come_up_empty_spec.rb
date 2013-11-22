require 'acceptance/acceptance_helper'

feature 'Sees feedback if they search for users and come up empty' do
  def expect_no_empty_result_message
    expect_no_content "Sorry, I couldn't find any users"
  end

  def expect_empty_result_message(search_string)
    expect_content "Sorry, I couldn't find any users with a name like \"#{search_string.downcase}\""
  end

  it "should have a cheerful message" do
    user = FactoryGirl.create(:user, :claimed)
    visit users_path(as: user)

    expect_no_empty_result_message

    search_string = "Four score and seven years ago"
    fill_in 'search_string', with: search_string
    click_button "Find!"

    expect_empty_result_message search_string
  end
end
