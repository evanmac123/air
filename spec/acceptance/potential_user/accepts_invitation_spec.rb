require 'acceptance/acceptance_helper'

feature "Potential User Accepts Invitation" do
  include SessionHelpers

  context "with no raffle" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @demo = @user.demo
      @potential_user = FactoryGirl.create(:potential_user, email: "john@snow.com", demo: @demo, primary_user: @user)
      @potential_user.is_invited_by @user
      visit invitation_path(@potential_user.invitation_code, demo_id: @demo.id, referrer_id: @user.id)
    end

    it "should get email with invitation" do
      open_email @potential_user.email
      current_email.to_s.should have_content "#{@user.name} invited you to"
      current_email.to_s.should have_content " join the #{@demo.name}"
    end

    it "should direct to activity page" do
      should_be_on activity_path
    end

    it "should show form for registration", js: true do
      expect_content "Enter your first and last name to continue:".upcase
    end

    it "should redirect from any other path to activity path" do
      visit users_path
      should_be_on activity_path
    end

    context "gives a name" do
      before(:each) do
        fill_in "potential_user_name", with: "my name"
        click_link "Next"
      end

      it "should register new user in the system", js: true do
        new_user = User.last
        new_user.name.should == "my name"
        new_user.email.should == @potential_user.email
      end

      it "should show welcome message", js: true do
        expect_content "Welcome, my"
        expect_current_board_header(@demo)
      end

      it "referrer should get email", js: true do
        new_user = User.last

        open_email @user.email
        current_email.to_s.should have_content "#{new_user.name} gave you credit for recruiting them. Many thanks and bonus points!"
      end
    end

    context "is invited to different boards simultaneusly" do
      before(:each) do
        @user2 = FactoryGirl.create(:user)
        @demo2 = @user2.demo
        @potential_user2 = FactoryGirl.create(:potential_user, email: "john@snow.com", demo: @demo2, primary_user: @user2)
        @potential_user2.is_invited_by @user2
      end


      it "should add 2 boards to 1 user", js: true do
        # first invitation
        should_be_on activity_path
        fill_in "potential_user_name", with: "my name"
        click_link "Next"
        expect_current_board_header(@demo)
        new_user = User.last
        # second invitation
        visit invitation_path(@potential_user.invitation_code, demo_id: @demo2.id, referrer_id: @user2.id)
        expect_current_board_header(@demo2)
      end
    end
  end

  context "in a board with a raffle" do
    it "should not show the prize modal", js: true do
      @user = FactoryGirl.create(:user)
      @demo = @user.demo
      @potential_user = FactoryGirl.create(:potential_user, email: "john@snow.com", demo: @demo)
      @potential_user.is_invited_by @user
      FactoryGirl.create(:raffle, :live, demo: @demo)

      visit invitation_path(@potential_user.invitation_code, demo_id: @demo.id, referrer_id: @user.id)
      expect_content "Enter your first and last name to continue:".upcase
      sleep 1 # yeah yeah yeah shut up I'm in no mood
      page.should have_no_content('New Raffle!')
    end
  end
end
