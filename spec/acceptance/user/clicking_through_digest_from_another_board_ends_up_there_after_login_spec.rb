require 'acceptance/acceptance_helper'

feature 'Clicking through digest from another board when claimed and logged out' do
  include SessionHelpers

  before do
    @user = FactoryGirl.create(:user, :claimed, email: "johnny@heythere.co.uk")
    @user.password = @user.password_confirmation = "foobar"
    @user.save!
    @other_board = FactoryGirl.create(:demo)
    @user.add_board(@other_board)

    @user.invite(nil, demo_id: @other_board.id)

    open_email("johnny@heythere.co.uk")
  end

  scenario 'gets logged in as user' do
    visit_in_email "Start"
    expect_current_board_header @other_board
  end

  scenario 'does not get logged in as client admin' do
    @user.update_attributes(is_client_admin:true)
    visit_in_email "Start"
    expect_content logged_out_message
  end
end
