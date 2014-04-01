require 'acceptance/acceptance_helper'

feature 'Clicking through digest from another board when claimed and logged out' do
  before do
    @user = FactoryGirl.create(:user, :claimed, email: "johnny@heythere.co.uk")
    @user.password = @user.password_confirmation = "foobar"
    @user.save!
    @other_board = FactoryGirl.create(:demo)
    @user.add_board(@other_board)

    @user.invite(nil, demo_id: @other_board.id)
    crank_dj_clear

    open_email("johnny@heythere.co.uk")
    visit_in_email "Start"
    expect_content "Please log in if you'd like to use the site."
  end

  scenario 'ends up there after login' do
    fill_in "session[email]", with: "johnny@heythere.co.uk"
    fill_in "session[password]", with: "foobar"
    click_button "Log In"
    expect_current_board_header @other_board
  end

  scenario 'ends up there after screwing up the login once and then doing it right' do
    fill_in "session[email]", with: "johnny@heythere.co.uk"
    fill_in "session[password]", with: ("foobar" + "derpderp")
    click_button "Log In"

    fill_in "session[email]", with: "johnny@heythere.co.uk"
    fill_in "session[password]", with: "foobar"
    click_button "Log In"
    expect_current_board_header @other_board
  end
end
