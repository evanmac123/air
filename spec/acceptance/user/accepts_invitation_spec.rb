require 'acceptance/acceptance_helper'

feature "User Accepts Invitation" do
  include SessionHelpers

  before(:each) do
    @demo = FactoryGirl.create :demo, :activated
    @user = FactoryGirl.create :claimed_user, demo: @demo, name: "Bob Q. Smith, III", password: "foobar"
    @unclaimed_user = FactoryGirl.create :user, name: "Bob Q. Smith, III"
  end

  def set_password_if_needed
    if @needs_password
      fill_in "user[password]", with: "foobar"
      click_button "Log in"
    end
  end

  describe "invitation acceptance for unclaimed user" do
    context "when all goes well" do
      before do
        visit invitation_url(@unclaimed_user.invitation_code)
        set_password_if_needed
      end

      it "sends them to the activity page" do
        should_be_on activity_path
      end

      it "welcomes them in das flash" do
        page.should have_content "Welcome, Bob"
      end
    end

    scenario "just one time" do
      visit invitation_url(@unclaimed_user.invitation_code)
      set_password_if_needed

      click_link "Sign Out"
      visit invitation_url(@unclaimed_user.invitation_code)

      should_be_on sign_in_path
      expect_content logged_out_message
    end
  end

  scenario "and gets no email after accepting invitation" do
    visit invitation_url(@user.invitation_code)
    set_password_if_needed
    crank_dj_clear

    ActionMailer::Base.deliveries.should be_empty
  end

  describe "is invited to other board" do
    describe "if user is already in the board" do
      before(:each) do
        @original_board = @user.demo
        @other_board = FactoryGirl.create(:demo)
        @user.add_board(@other_board)
        @user.demos.should have(2).demos
        @user.demo.should == @original_board
        @original_board.should_not == @other_board
      end

      scenario "and user is signed in then it goes well" do
        signin_as @user, 'foobar'
        visit invitation_url(@user.invitation_code, demo_id: @other_board.id)
        should_be_on activity_path
        expect_current_board_header(@other_board)
      end

      scenario "and user is not signed in then he comes to sign in page" do
        visit invitation_url(@user.invitation_code, demo_id: @other_board.id)
        should_be_on sign_in_path
      end
    end

    describe "if user is not in the board" do
      scenario "and is invited to public board then it goes well" do
        original_board = @unclaimed_user.demo
        @other_board = @demo
        visit invitation_path @unclaimed_user.invitation_code, demo_id: @demo.id, referrer_id: @user.id

        should_be_on activity_path
        expect_current_board_header(@other_board)
        expect_content "Welcome"

        @unclaimed_user.demos.should have(2).demos
        @unclaimed_user.reload.demo.should == @other_board
        original_board.should_not == @other_board
      end

      scenario "and is invited to private board then he is not added to it" do
        original_board = @user.demo
        @other_board = FactoryGirl.create(:demo, is_public: false)

        visit invitation_url(@user.invitation_code, demo_id: @other_board.id)

        should_be_on activity_path
        expect_current_board_header(original_board)

        @user.demos.should have(1).demo
      end
    end
  end

  scenario "unclaimed user gets seed points on accepting invitation to game with them, but just once" do
    @unclaimed_user.demo.update_attributes(seed_points: 10)

    visit invitation_url(@unclaimed_user.invitation_code)

    should_be_on activity_path
    expect_content "10 pts #{@user.name} joined"
  end
end
