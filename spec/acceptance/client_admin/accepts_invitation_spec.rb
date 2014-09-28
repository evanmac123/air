require 'acceptance/acceptance_helper'

feature "Client Admin Accepts Invitation" do
  include SessionHelpers

  before(:each) do
    @demo = @demo = FactoryGirl.create :demo, :activated
    @user = FactoryGirl.create :user, is_client_admin: true, demo: @demo
  end

  def fill_in_required_invitation_fields
    fill_in("Choose a password", :with => 'whatwhat')
  end

  def expect_terms_and_conditions_language
    expect_content "By submitting this form or using this site, you are agreeing to the terms and conditions"
  end

  scenario "when all goes well" do
    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"

    should_be_on activity_path
    expect_content "#{@user.name} joined"

    ActionMailer::Base.deliveries.clear
    crank_dj_clear
    ActionMailer::Base.deliveries.should be_empty # no validation code to email
  end

  scenario "across boards" do
    original_board = @user.demo
    @other_board = FactoryGirl.create(:demo)
    @user.add_board(@other_board)
    @user.demos.should have(2).demos
    @user.demo.should == original_board
    original_board.should_not == @other_board

    visit invitation_url(@user.invitation_code, demo_id: @other_board.id)
    fill_in_required_invitation_fields
    click_button "Log in"

    should_be_on activity_path
    expect_current_board_header(@other_board)
  end

  scenario "accepts invitation to a game with a custom welcome message" do
    @user.demo.update_attributes(custom_welcome_message: "You, %{unique_id}, are in the %{name} game.")
    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"

    expect_content "#{@user.name} joined!"
  end

  scenario "user gets seed points on accepting invitation to game with them, but just once" do
    @user.demo.update_attributes(seed_points: 10)

    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"

    should_be_on activity_path
    expect_content "10 pts #{@user.name} joined"
  end

  scenario "user must set password when accepting invitation" do
    visit invitation_url(@user.invitation_code)
    click_button "Log in"

    expect_no_content "Welcome to the game"
    expect_content "Please choose a password"

  end

  scenario "user sets password, with no confirmation needed" do
    visit invitation_url(@user.invitation_code)
    fill_in "Choose a password", :with => "foofoo"
    click_button "Log in"

    click_link "Sign Out"

    fill_in "session[email]", :with => @user.email
    fill_in "session[password]", :with => 'foofoo'
    click_button "Log In"

    should_be_on activity_path(:format => 'html')
  end

  scenario "just one time" do
    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"

    click_link "Sign Out"
    visit invitation_url(@user.invitation_code)

    should_be_on sign_in_path
    expect_content logged_out_message
  end

  scenario "and gets no email after accepting invitation" do
    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"

    crank_dj_clear

    ActionMailer::Base.deliveries.should be_empty
  end

  scenario "User gets logged in only when accepting invitation, not when at acceptance form" do
    visit invitation_page(@user)
    visit activity_page
    should_be_on(signin_page)
    visit invitation_page(@user)

    fill_in_required_invitation_fields
    click_button 'Log in'
    should_be_on(activity_page)
  end

  context "when there is no client name specified for the demo" do
    before(:each) do
      @user.demo.client_name.should_not be_present
    end

    it "should not say \"Sponsored by\"" do
      visit invitation_page(@user)
      expect_no_content "Sponsored by"
    end
  end

  it "should have a link to the T&Cs" do
    visit invitation_url(@user.invitation_code)
    expect_terms_and_conditions_language
    click_link "terms and conditions"
    should_be_on terms_path
  end

  it "should send ping on friend invitation acceptance" do
    inviter = FactoryGirl.create :user
    visit invitation_path(@user.invitation_code, demo_id: inviter.demo.id, referrer_id: inviter.id)

    expect_ping "User - New", {source: "User - Friend Invitation"}, @user
  end
end
