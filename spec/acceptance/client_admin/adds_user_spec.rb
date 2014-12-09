require 'acceptance/acceptance_helper'

feature 'Adds user' do
  let (:client_admin) { FactoryGirl.create(:client_admin) }
  let (:demo)         { client_admin.demo }
  before do
    FactoryGirl.create :tile, demo: demo
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

    click_link "More options"
    fill_in "user[employee_id]", :with => "012345"
    fill_in "user[zip_code]",    :with => "02139"

    select "Boston", :from => "user[location_id]"
  end

  def create_characteristics(demo)
    @boolean_characteristic = FactoryGirl.create :characteristic, :boolean, name: "Likes cats", demo_id: demo.id
    @date_characteristic = FactoryGirl.create :characteristic, :date, name: "Date of last teeth cleaning", demo_id: demo.id
    @number_characteristic = FactoryGirl.create :characteristic, :number, name: "Remaining teeth", demo_id: demo.id
    @time_characteristic = FactoryGirl.create :characteristic, :time, name: "Lunchtime", demo_id: demo.id
    @discrete_characteristic = FactoryGirl.create :characteristic, :discrete, name: "Favorite Beatle", allowed_values: %w(John Paul George Ringo), demo_id: demo.id
  end

  def create_locations(demo)
    %w(Atlanta Boston Cleveland Detroit).each {|name| demo.locations.create!(name: name)}
  end

  def newest_user(demo)
    demo.users.order("created_at DESC").first  
  end

  def expect_new_user(demo, with_details=true)
    new_user = newest_user(demo)
    new_user.email.should == "jemsh@example.com"
    new_user.claim_code.should be_present
    expect_add_message new_user.name, new_user.claim_code, invitation_url(new_user.invitation_code, protocol: 'https')

    if with_details
      new_user.name.should == "Jehosaphat Emshwiller"
      new_user.employee_id.should == "012345"
      new_user.zip_code.should == "02139"
    end
  end

  before do
    create_characteristics(demo)
    create_locations(demo)
    visit client_admin_users_path(as: client_admin)
  end

  it "should work when all entered data is valid", js: true do
    demo.users.count.should == 1 # just the admin

    fill_in_user_information
    click_button "Add User"

    should_be_on client_admin_users_path

    demo.users.reload.count.should == 2
    expect_new_user(demo)
    newest_user(demo).demos.should have(1).demo
  end

  it 'should make user with user role', js: true do
    demo.users.count.should == 1 # just the admin

    fill_in_user_information
    page.find('select.user-role-select').select 'User'
    click_button "Add User"

    should_be_on client_admin_users_path

    demo.users.reload.count.should == 2
    new_user = demo.users.order("created_at DESC").first
    new_user.is_client_admin.should == false    
  end
  
  it 'should make user with user role', js: true do
    demo.users.count.should == 1 # just the admin

    fill_in_user_information
    page.find('select.user-role-select').select 'Administrator'
    click_button "Add User"

    should_be_on client_admin_users_path

    demo.users.reload.count.should == 2
    new_user = demo.users.order("created_at DESC").first
    new_user.is_client_admin.should == true    
  end

  it 'should ping if new user is client admin', js: true do
    fill_in_user_information
    page.find('select.user-role-select').select 'Administrator'
    click_button "Add User"

    FakeMixpanelTracker.clear_tracked_events 
    crank_dj_clear 
    FakeMixpanelTracker.should have_event_matching("Creator - New", source: 'Client Admin')
  end
  
  it "should show meaningful errors when entered data is invalid" do
    click_button "Add User"
    should_be_on client_admin_users_path

    demo.users.reload.count.should == 1
    expect_add_failed_message "Please enter a first and last name"
  end

  it "should generate unique claim codes for each user" do
    2.times do
      fill_in "user[name]", with: "John Smith"
      click_button "Add User"
    end

    john_smiths = demo.reload.users.where(name: "John Smith")
    john_smiths.length.should == 2
    john_smiths[0].claim_code.should_not == john_smiths[1].claim_code
  end

  it "should send a mixpanel ping", js: true do
    fill_in_user_information
    click_button "Add User"
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear

    FakeMixpanelTracker.should have_event_matching('User - New', source: 'creator')
  end

  context "if we try to add an existing user" do
    it "should allow them, if not already in the board, to be invited", js: true do
      FactoryGirl.create(:user, email: USER_EMAIL)
      fill_in_user_information

      click_button "Add User"

      page.should have_no_content("Email has already been taken.")
      expect_new_user(demo, false)
      newest_user(demo).demos.should have(2).demos
    end

    it "shouldn't appear to allow you to re-invite an existing user", js: true do
      FactoryGirl.create(:user, email: USER_EMAIL, demo: demo)
      fill_in_user_information

      click_button "Add User"
      newest_user(demo).demos.should have(1).demo
      page.should have_content("It looks like #{USER_EMAIL} is already in your board.")
    end

    it "should give a more appropriate mixpanel ping on inviting existing user", js: true do
      FactoryGirl.create(:user, email: USER_EMAIL)
      fill_in_user_information

      click_button "Add User"
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should_not have_event_matching('User - New', source: 'creator')
      FakeMixpanelTracker.should have_event_matching('User - Existing Invited', source: 'creator')
    end

    it "should have the correct board name in the invitation", js: true do
      user = FactoryGirl.create(:user, email: USER_EMAIL)
      user.demo.should_not == demo

      fill_in_user_information

      click_button "Add User"
      click_link "Next, send invite to #{user.name}"
      crank_dj_clear

      open_email user.email
      current_email.to_s.should_not include(user.demo.name)
      current_email.to_s.should include(demo.name)
    end
  end
end
