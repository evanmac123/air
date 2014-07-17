require 'acceptance/acceptance_helper'

feature 'Signed-in user going to a public board' do
  before(:each) do
    @board = FactoryGirl.create(:demo, :with_public_slug)
    @users_board = FactoryGirl.create(:demo, :with_public_slug)
    @user = FactoryGirl.create(:user, :claimed, demo: @users_board)
    visit activity_path(as: @user) # even by the back door, this sets the cookie
    visit public_board_path(@board.public_slug)
  end
  it 'should be redirected to the ordinary activity page of this public demo' do
    should_be_on activity_path
  end

  it "should add this board to user boards and set it as current" do
    @user.reload.demo.should == @board
  end

  it "should be redirected to activity page of his board when he visits it" do
    visit public_board_path(@users_board.public_slug)
    @user.reload.demo.should == @users_board

    visit public_board_path(@users_board.public_slug)
    @user.reload.demo.should == @users_board
  end
end
