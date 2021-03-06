require 'acceptance/acceptance_helper'

feature 'Adds user' do
  let (:client_admin) { FactoryBot.create(:client_admin) }
  let (:demo) { client_admin.demo }

  before do
    FactoryBot.create :tile, demo: demo
  end

  before do
    visit client_admin_users_path(as: client_admin)
  end

  it "should work when all entered data is valid", js: true do
    expect(demo.users.count).to eq(1) # just the admin

    fill_in_user_information
    click_button "Add User"

    should_be_on client_admin_users_path
  end

  it "should strip email", js: true do
    expect(demo.users.count).to eq(1) # just the admin

    fill_in_user_information
    fill_in "user[email]",       :with => " jemsh@example.com   "

    click_button "Add User"
    expect(demo.users.reload.count).to eq(2)
    expect_new_user(demo, false)
    expect(newest_user(demo).demos.size).to eq(1)
  end

  it 'should make user with user role', js: true do
    expect(demo.users.count).to eq(1) # just the admin

    fill_in_user_information
    select_role("User")
    click_button "Add User"

    should_be_on client_admin_users_path

    expect_content "Success! Next, send invite to"

  end

  it 'should make user with Admin role', js: true do
    expect(demo.users.count).to eq(1) # just the admin
    fill_in_user_information
    select_role("Administrator")
    click_button "Add User"

    expect_content "Success! Next, send invite to"
  end

  it "should show meaningful errors when entered data is invalid" do
    click_button "Add User"
    should_be_on client_admin_users_path

    expect_add_failed_message "Please enter a first and last name"
  end

  #FIXME this functionality may no longer be used in the system. 2016-07-16
  it "should generate unique claim codes for each user" do
    [1,2].each do|num|
      fill_in "user[name]", with: "John Smith"
      fill_in "user[email]", :with => "jemsh#{num}@example.com"
      click_button "Add User"
    end

    john_smiths = demo.reload.users.where(name: "John Smith")
    expect(john_smiths.length).to eq(2)
    expect(john_smiths[0].claim_code).not_to eq(john_smiths[1].claim_code)
  end

  context "if we try to add an existing user" do
    it "should allow them, if not already in the board, to be invited", js: true do
      FactoryBot.create(:user, email: USER_EMAIL)
      fill_in_user_information

      click_button "Add User"

      expect(page).to have_no_content("Email has already been taken.")

      #FIXME these two conditions should be tested in unit tests
      #-----expect_new_user(demo, false)
      #-----newest_user(demo).demos.should have(2).demos
    end

    it "shouldn't appear to allow you to re-invite an existing user", js: true do
      FactoryBot.create(:user, email: USER_EMAIL, demo: demo)
      fill_in_user_information

      click_button "Add User"
      expect_content("It looks like #{USER_EMAIL} is already in your board.")
    end

    it "should have the correct board name in the invitation", js: true do
      user = FactoryBot.create(:user, email: USER_EMAIL)
      expect(user.demo).not_to eq(demo)

      fill_in_user_information

      click_button "Add User"
      click_link "Next, send invite to #{user.name}"
      

      open_email user.email
      expect(current_email.to_s).not_to include(user.demo.name)
      expect(current_email.to_s).to include(demo.name)
    end
  end

  def expect_add_message(name, claim_code, url)
    # Hack to account for the fact that when we use Poltergeist, it generates
    # an invitation URL based on the server it itself is running

    if Capybara.current_driver == :poltergeist
      url.gsub!("www.example.com", "127.0.0.1:#{page.server.port}")
    end

    expect_content "Success! Next, send invite to #{name}"
  end

  def expect_add_failed_message(error)
    expect_content "Sorry, we weren't able to add that user. #{error}"
  end

  USER_EMAIL = "jemsh@example.com"

  def fill_in_user_information
    fill_in "user[name]",        :with => "Jehosaphat Emshwiller"
    fill_in "user[email]",       :with => USER_EMAIL
  end

  def newest_user(demo)
    demo.users.order("created_at DESC").first
  end

  def expect_new_user(demo, with_details=true)
    new_user = newest_user(demo)
    expect(new_user.email).to eq("jemsh@example.com")
    expect(new_user.claim_code).to be_present
    expect_add_message new_user.name, new_user.claim_code, invitation_url(new_user.invitation_code, protocol: 'https')

    if with_details
      expect(new_user.name).to eq("Jehosaphat Emshwiller")
    end
  end

  def select_role role
    page.find('.custom.user-role-select').click
    within '.custom.user-role-select' do
      page.find("li", text: role).click
    end
  end

end
