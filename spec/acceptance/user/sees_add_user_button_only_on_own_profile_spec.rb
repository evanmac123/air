require 'acceptance/acceptance_helper'

feature 'Sees add user button' do
  def add_user_buttons
    page.all("a[href='#{users_path}']", text: 'Add')
  end

  def expect_add_user_button
    expect(add_user_buttons).not_to be_empty
  end

  def expect_no_add_user_button
    expect(add_user_buttons).to be_empty
  end

  before do
    @user = FactoryGirl.create :user
  end

  it "on their own profile page" do
    visit user_path(@user, as: @user)
    expect_add_user_button
  end

  it "not on another user's profile page" do
    other_user = FactoryGirl.create :user, demo: @user.demo
    visit user_path(other_user, as: @user)
    expect_no_add_user_button
  end
end
