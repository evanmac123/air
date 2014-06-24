require 'acceptance/acceptance_helper'

feature "User Accepts Invitation" do

  before(:each) do
    @user = FactoryGirl.create :user, name: "Bob Q. Smith, III"
  end

  context "when all goes well" do
    before do
      visit invitation_url(@user.invitation_code)
    end

    it "sends them to the activity page" do
      should_be_on activity_path
    end

    it "welcomes them in das flash" do
      page.should have_content "Welcome, Bob"
    end
  end

  scenario "across boards" do
    original_board = @user.demo
    @other_board = FactoryGirl.create(:demo)
    @user.add_board(@other_board)
    @user.demos.should have(2).demos
    @user.demo.should == original_board
    original_board.should_not == @other_board

    visit invitation_url(@user.invitation_code, demo_id: @other_board.id)

    should_be_on activity_path
    expect_current_board_header(@other_board)
  end

  scenario "accepts invitation to a game with a custom welcome message" do
    @user.demo.update_attributes(custom_welcome_message: "You, %{unique_id}, are in the %{name} game.")
    visit invitation_url(@user.invitation_code)

    should_be_on activity_path
  end

  scenario "user gets seed points on accepting invitation to game with them, but just once" do
    @user.demo.update_attributes(seed_points: 10)

    visit invitation_url(@user.invitation_code)

    should_be_on activity_path
    expect_content "10 pts #{@user.name} joined"
  end

  scenario "user accepts invitation before game begins" do
    @user.demo.update_attributes(begins_at: Chronic.parse("May 1, 2030, 12:00 PM"))

    visit invitation_url(@user.invitation_code)

    should_be_on activity_path
    expect_content "Your game begins on May 01, 2030 at 12:00 PM Eastern."
    @user.reload.should be_claimed

    visit activity_path
    expect_content "Your game begins on May 01, 2030 at 12:00 PM Eastern."
  end

  scenario "just one time" do
    visit invitation_url(@user.invitation_code)

    click_link "Sign Out"
    visit invitation_url(@user.invitation_code)

    should_be_on sign_in_path
    expect_content "You've already accepted your invitation to the game. Please log in if you'd like to use the site."
  end

  scenario "and gets no email after accepting invitation" do
    visit invitation_url(@user.invitation_code)

    crank_dj_clear

    ActionMailer::Base.deliveries.should be_empty
  end
end
