require 'acceptance/acceptance_helper'

feature "Client Admin Accepts Invitation" do
  include SessionHelpers

  before(:each) do
    @demo = @demo = FactoryBot.create :demo, :activated
    FactoryBot.create(:tile, is_public: true)
    @user = FactoryBot.create :user, is_client_admin: true, demo: @demo
  end

  def fill_in_required_invitation_fields
    fill_in("user_password", with: 'whatwhat')
  end

  def expect_terms_and_conditions_language
    expect_content "By submitting this form or using this site, you are agreeing to the terms and conditions"
  end

  scenario "when all goes well" do
    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"

    should_be_on explore_path
  end

  scenario "across boards" do
    original_board = @user.demo
    @other_board = FactoryBot.create(:demo)
    @user.add_board(@other_board)
    expect(@user.demos.size).to eq(2)
    expect(@user.demo).to eq(original_board)
    expect(original_board).not_to eq(@other_board)

    visit invitation_url(@user.invitation_code, demo_id: @other_board.id)
    fill_in_required_invitation_fields
    click_button "Log in"

    should_be_on activity_path
    expect_current_board_header(@other_board)
  end

  scenario "user must set password when accepting invitation" do
    visit invitation_url(@user.invitation_code)
    expect_content "Please choose a password"

    click_button "Log in"

    within ".form-msg" do
      expect_content "Please choose a password"
    end
  end

  scenario "user sets password, with no confirmation needed" do
    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"

    should_be_on explore_path
  end

  scenario "just one time" do
    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"

    click_link "Sign Out"
    visit invitation_url(@user.invitation_code)

    should_be_on root_path
    expect(page).to have_selector('#flash', visible: false, text: logged_out_message)
  end

  scenario "and gets no email after accepting invitation" do
    visit invitation_url(@user.invitation_code)
    fill_in_required_invitation_fields
    click_button "Log in"



    expect(ActionMailer::Base.deliveries).to be_empty
  end

  scenario "User gets logged in only when accepting invitation, not when at acceptance form" do
    visit invitation_page(@user)
    visit activity_page
    should_be_on(root_path)
    visit invitation_page(@user)

    fill_in_required_invitation_fields
    click_button 'Log in'
    should_be_on(explore_path)
  end

  context "when there is no client name specified for the demo" do
    before(:each) do
      expect(@user.demo.client_name).not_to be_present
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

  it "should not require a password if the user is a new lead" do
    visit invitation_url(@user.invitation_code, { new_lead: true })
    should_be_on(explore_path)
  end
end
