require 'acceptance/acceptance_helper'

feature 'Sets their privacy level' do
  before do
    @user = FactoryGirl.create(:user, name: 'MainGuy')

    @user_in_same_board = FactoryGirl.create(:user, demo: @user.demo)

    @follower = FactoryGirl.create(:user, demo: @user.demo)
    @follower.befriend(@user)
    @user.accept_friendship_from(@follower)
  end

  def expect_act_copy
    expect_content "#{@user.name} ate puppy less than a minute ago"
  end

  def expect_no_act_copy
    expect_no_content "ate puppy"
  end

  def create_act
    FactoryGirl.create(:act, user: @user, text: 'ate puppy')
  end

  scenario 'Privacy level of "everybody" shows act to everybody in board' do
    @user.update_attributes(privacy_level: 'everybody')
    create_act

    visit acts_path(as: @user_in_same_board)
    expect_act_copy
  end

  scenario 'Privacy level of "connected" shows act to friends in board only' do
    @user.update_attributes(privacy_level: 'connected')
    create_act
    
    visit acts_path(as: @user_in_same_board)
    expect_no_act_copy

    visit acts_path(as: @follower)
    expect_act_copy
  end

  scenario 'Privacy level of "nobody" shows acts to nobody' do
    @user.update_attributes(privacy_level: 'nobody')
    create_act
    
    visit acts_path(as: @user_in_same_board)
    expect_no_act_copy

    visit acts_path(as: @follower)
    expect_no_act_copy
  end

  %w(everybody connected nobody).each do |privacy_level|
    scenario "A user with a privacy level of \"#{privacy_level}\" can see their own acts, regardless of what anyone else can" do
      @user.update_attributes(privacy_level: privacy_level)
      create_act
      visit acts_path(as: @user)
      expect_act_copy
    end
  end

  scenario "sets their privacy level in the settings page" do
    visit edit_account_settings_path(as: @user)
    page.find('#user_privacy_level').value.should == 'connected'

    select 'Everybody', from: 'user[privacy_level]'
    click_button "Update privacy"
    page.find('#user_privacy_level').value.should == 'everybody'
  end

  scenario "privacy level change affects existing acts" do
    @user.update_attributes(privacy_level: 'everybody')
    create_act

    visit acts_path(as: @user_in_same_board)
    expect_act_copy
    visit acts_path(as: @follower)
    expect_act_copy

    visit edit_account_settings_path(as: @user)
    select "Connections I've accepted", from: 'user[privacy_level]'
    click_button "Update privacy"

    visit acts_path(as: @user_in_same_board)
    expect_no_act_copy
    visit acts_path(as: @follower)
    expect_act_copy

    visit edit_account_settings_path(as: @user)
    select "Everybody", from: 'user[privacy_level]'
    click_button "Update privacy"

    visit acts_path(as: @user_in_same_board)
    expect_act_copy
    visit acts_path(as: @follower)
    expect_act_copy
  end
end
