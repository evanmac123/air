require 'acceptance/acceptance_helper'

feature "User Accepts Invitation" do

  before(:each) do
    @user = FactoryGirl.create :user
  end

  def fill_in_acceptance_page_fields(use_phone = true, check_t_and_c = true)
    fill_in("Enter your mobile number", :with => "508-740-7520") if use_phone
    fill_in("Choose a password", :with => 'whatwhat')
    fill_in("Confirm password", :with => 'whatwhat')
    check("Terms and conditions") if check_t_and_c
  end

  scenario "throws error message if T&Cs not accepted" do
    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields(false, false)
    click_button 'Log in'
    expect_content "You must accept the terms and conditions"
  end

  scenario "when all goes well" do
    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields
    click_button "Log in"

    should_be_on phone_verification_path

    crank_dj_clear
    expect_mt_sms_including("+15087407520", @user.reload.new_phone_validation)
    fill_in "user[new_phone_validation]", :with => @user.new_phone_validation
    click_button "Enter"

    should_be_on activity_path
    expect_content "#{@user.name} joined the game"

    ActionMailer::Base.deliveries.clear
    crank_dj_clear
    expect_mt_sms "+15087407520", "You've joined the #{@user.demo.name} game! Your username is #{@user.sms_slug} (text MYID if you forget). To play, text to this #."
    ActionMailer::Base.deliveries.should be_empty # no validation code to email
  end

  scenario "doesn't see the phone validation interstitial if they don't enter a phone number" do
    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields(false)
    click_button "Log in"

    should_be_on activity_path
  end

  scenario "gets a second try at the validation page if they have trouble with it" do
    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields
    click_button "Log in"

    fill_in "user[new_phone_validation]", :with => 'ohheyiamstupid'
    click_button "Enter"

    should_be_on phone_verification_path
    expect_content "Sorry, the code you entered was invalid. Please try typing it again."
  end

  scenario "accepts invitation to a game with a custom welcome message" do
    @user.demo.update_attributes(custom_welcome_message: "You, %{unique_id}, are in the %{name} game.")
    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields
    click_button "Log in"

    fill_in "user[new_phone_validation]", :with => @user.reload.new_phone_validation
    click_button "Enter"

    crank_dj_clear
    expect_mt_sms("+15087407520", "You, #{@user.sms_slug}, are in the #{@user.demo.name} game.")
  end

  scenario "user gets seed points on accepting invitation to game with them, but just once" do
    @user.demo.update_attributes(seed_points: 10)

    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields(false)
    click_button "Log in"

    should_be_on activity_path
    expect_content "10 pts #{@user.name} joined the game"
  end

  scenario "user can and must set password when accepting invitation" do
    visit invitation_url(@user.invitation_code)
    click_button "Log in"

    expect_no_content "Welcome to the game"
    expect_content "Please choose a password"
    expect_content "Please enter the password here too"

    fill_in "Choose a password", :with => "foofoo"
    fill_in "Confirm password", :with => "barbar"
    click_button "Log in"

    expect_no_content "Welcome to the game"
    expect_content "Sorry, your passwords don't match"

    fill_in "Choose a password", :with => "foofoo"
    fill_in "Confirm password", :with => "foofoo"
    check("Terms and conditions")
    click_button "Log in"
    
    click_link "Sign Out"

    fill_in "session[email]", :with => @user.email
    fill_in "session[password]", :with => 'foofoo'
    click_button "Let's play!"

    should_be_on activity_path(:format => 'html')
  end

  scenario "user accepts invitation before game begins" do
    @user.demo.update_attributes(begins_at: Chronic.parse("May 1, 2030, 12:00 PM"))

    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields
    click_button "Log in"

    should_be_on phone_verification_path
    expect_no_content "Your game begins on May 01, 2030 at 12:00 PM Eastern."

    fill_in "user[new_phone_validation]", :with => @user.reload.new_phone_validation
    click_button "Enter"

    should_be_on activity_path
    expect_content "Your game begins on May 01, 2030 at 12:00 PM Eastern."
    @user.reload.should be_claimed
    @user.phone_number.should == "+15087407520"

    visit activity_path
    expect_content "Your game begins on May 01, 2030 at 12:00 PM Eastern."
  end

  scenario "just one time" do
    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields
    click_button "Log in"

    click_link "Sign Out"
    visit invitation_url(@user.invitation_code)

    should_be_on sign_in_path
    expect_content "You've already accepted your invitation to the game. Please log in if you'd like to use the site."
  end

  scenario "gets proper copy in welcome email" do
    visit invitation_url(@user.invitation_code)
    fill_in_acceptance_page_fields
    click_button "Log in"

    crank_dj_clear
    ActionMailer::Base.deliveries.last.to_s.should_not include("@{reply here}")
    ActionMailer::Base.deliveries.last.to_s.should include("If you'd like to play by e-mail instead of texting or going to the website, you can always send your commands to play@playhengage.com.")
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

  context "when there is a client name specified for the demo" do
    before(:each) do
      @user.demo.update_attributes(client_name: "BigCorp")
    end

    it "should say who sponsored the game" do
      visit invitation_page(@user)
      expect_content "Sponsored by: BigCorp"
    end
  end
end
