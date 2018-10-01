require 'acceptance/acceptance_helper'

feature "User Accepts Invitation" do
  include SessionHelpers

  before(:each) do
    @demo = FactoryBot.create :demo, :activated
    @user = FactoryBot.create :claimed_user, demo: @demo, name: "Bob Q. Smith, III", password: "foobar"
    @unclaimed_user = FactoryBot.create :user, name: "Bob Q. Smith, III"
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
        expect(page).to have_content "Welcome, Bob"
      end
    end

    scenario "just one time" do
      visit invitation_url(@unclaimed_user.invitation_code)
      set_password_if_needed

      click_link "Sign Out"
      visit invitation_url(@unclaimed_user.invitation_code)

      should_be_on root_path
      expect(page).to have_selector('#flash', visible: false, text: logged_out_message)
    end
  end

  scenario "and gets no email after accepting invitation" do
    visit invitation_url(@user.invitation_code)
    set_password_if_needed

    expect(ActionMailer::Base.deliveries).to be_empty
  end

  describe "is invited to other board" do
    describe "if user is already in the board" do
      before(:each) do
        @original_board = @user.demo
        @other_board = FactoryBot.create(:demo)
        @user.add_board(@other_board)
        expect(@user.demos.size).to eq(2)
        expect(@user.demo).to eq(@original_board)
        expect(@original_board).not_to eq(@other_board)
      end

      xscenario "and user is signed in then it goes well", js: true do
        signin_as @user, 'foobar'
        visit invitation_url(@user.invitation_code, demo_id: @other_board.id)
        should_be_on activity_path
        expect_current_board_header(@other_board)
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

        expect(@unclaimed_user.demos.size).to eq(2)
        expect(@unclaimed_user.reload.demo).to eq(@other_board)
        expect(original_board).not_to eq(@other_board)
      end

      scenario "and is invited to private board then he is not added to it" do
        original_board = @user.demo
        @other_board = FactoryBot.create(:demo, is_public: false)

        visit invitation_url(@user.invitation_code, demo_id: @other_board.id)

        should_be_on activity_path
        expect_current_board_header(original_board)

        expect(@user.demos.size).to eq(1)
      end
    end
  end
end
