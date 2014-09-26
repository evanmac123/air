require 'acceptance/acceptance_helper'

feature "Potential User Accepts Invitation" do
  include SessionHelpers

  before(:each) do
    @user = FactoryGirl.create(:user)
    @demo = @user.demo
    @potential_user = FactoryGirl.create(:potential_user, email: "john@snow.com", demo: @demo)
    @potential_user.is_invited_by @user
    visit invitation_path(@potential_user.invitation_code, demo_id: @demo.id, referrer_id: @user.id)
  end

  it "should get email with invitation" do
    open_email @potential_user.email
    current_email.to_s.should have_content "#{@user.name} invitated you to"
    current_email.to_s.should have_content " join the #{@demo.name}"
  end

  it "should be directed to activity page" do
    should_be_on activity_path
  end

  it "should have form for registration", js: true do
    expect_content "Enter your first and last name to continue:"
  end

  it "should be redirected from any other path to activity path" do
    visit users_path
    should_be_on activity_path
  end

  context "gives a name" do
    before(:each) do
      fill_in "potential_user_name", with: "my name"
      click_button "Next"
    end

    it "should register new user in the system", js: true do
      new_user = User.last
      new_user.name.should == "my name"
      new_user.email.should == @potential_user.email
    end

    it "should show welcome message", js: true do
      expect_content "Welcome, my"
    end

    it "referrer should get email", js: true do
      new_user = User.last

      open_email @user.email
      current_email.to_s.should have_content "#{new_user.name} gave you credit for recruiting them. Many thanks and bonus points!"
    end
  end
end 