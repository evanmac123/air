require 'acceptance/acceptance_helper'

feature 'Signed-in user going to a public board' do
  before(:each) do
    @board = FactoryBot.create(:demo, :with_public_slug)
    @users_board = FactoryBot.create(:demo, :with_public_slug)
    @user = FactoryBot.create(:user, :claimed, demo: @users_board)
    visit activity_path(as: @user) # even by the back door, this sets the cookie
    visit public_board_path(@board.public_slug)
  end
  it 'should be redirected to the ordinary activity page of this public demo' do
    should_be_on activity_path
  end

  it "should add this board to user boards and set it as current" do
    expect(@user.reload.demo).to eq(@board)
  end

  it "should see flash message" do
    expect_content "You've now joined the #{@board.name} board!" 
  end

  it "should be redirected to activity page of his board when he visits it" do
    visit public_board_path(@users_board.public_slug)
    expect(@user.reload.demo).to eq(@users_board)

    visit public_board_path(@users_board.public_slug)
    expect(@user.reload.demo).to eq(@users_board)
  end

  it "should see flash message" do
    visit public_board_path(@users_board.public_slug)
    expect_no_content "You've now joined the #{@users_board.name} board!" 
  end
end
