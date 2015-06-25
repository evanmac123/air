require 'acceptance/acceptance_helper'

feature 'Edits user' do
  let (:client_admin)   { FactoryGirl.create(:client_admin) }
  let (:demo)           { client_admin.demo }
  let (:unclaimed_user) { FactoryGirl.create(:user, demo: demo) }

  let (:user) do
    FactoryGirl.create(:user, 
                       :claimed, 
                       demo:          demo,
                       name:          "Francis X. McGillicuddy",
                       email:         "frank@example.com",
                       phone_number:  "+14155551212",
                       date_of_birth: Date.parse("1977-04-17"),
                       gender:        "male",
                       employee_id:   "12345",
                       zip_code:      "02139"
                      )
  end
  
  before do
    FactoryGirl.create :tile, demo: demo
  end

  def expect_name(expected_name)
    page.find("input#user_name").value.should == expected_name
  end

  def expect_email(expected_email)
    page.find("input#user_email").value.should == expected_email
  end

  def expect_phone_number(expected_phone_number)
    page.find("input#user_phone_number").value.should == expected_phone_number
  end

  def expect_role(expected_role)
    page.find('select.user-role-select').value.should == expected_role
  end

  it "should update of the same attributes as creation" do
    visit(edit_client_admin_user_path(user, as: client_admin))
    expect_name "Francis X. McGillicuddy"
    expect_email "frank@example.com"
    expect_phone_number "(415) 555-1212"

    fill_in "Name",         :with => "Frances McGillicuddy"
    fill_in "Email",        :with => "fran@example.com"
    fill_in "Phone number", :with => "415-555-1213"

    click_button "Save edits"
    expect_name "Frances McGillicuddy"
    expect_email "fran@example.com"
    expect_phone_number "(415) 555-1213"

    expect_content "OK, we've updated this user's information"
  end
  
  it 'should have user set with role user at creation' do
    visit(edit_client_admin_user_path(user, as: client_admin))
    expect_role('User')
  end
  
  it 'should change user roles when selected' do
    visit(edit_client_admin_user_path(user, as: client_admin))
    page.find('select.user-role-select').select 'Administrator'
    click_button "Save edits"
    user.reload.role_in(client_admin.demo).should eq 'Administrator'
    expect_role('Administrator')
    
    page.find('select.user-role-select').select 'User'
    click_button "Save edits"
    user.reload.role_in(client_admin.demo).should eq 'User'
    expect_role('User')    
  end
  
  it 'should set user with role Administrator when selected' do
    visit(edit_client_admin_user_path(user, as: client_admin))
    page.find('select.user-role-select').select 'Administrator'
    click_button "Save edits"
    user.reload.role_in(client_admin.demo).should eq 'Administrator'
    expect_role('Administrator')
  end

  it 'should make ping if user was given role Administrator' do
    visit(edit_client_admin_user_path(user, as: client_admin))
    page.find('select.user-role-select').select 'Administrator'
    click_button "Save edits"
    
    FakeMixpanelTracker.clear_tracked_events 
    crank_dj_clear 
    FakeMixpanelTracker.should have_event_matching("Creator - New", source: 'Client Admin')
  end
  
  it "should show errors on bad data" do
    visit(edit_client_admin_user_path(user, as: client_admin))
    expect_name "Francis X. McGillicuddy"
    expect_email "frank@example.com"
    expect_phone_number "(415) 555-1212"

    fill_in "Name", :with => ""

    click_button "Save edits"

    expect_content "Sorry, we weren't able to change that user's information. Please enter a first and last name"
    expect_name "" # but we keep the bad data so we can continue editing it
  end

  it "should allow a valid update after fixing a failed update" do
    # To address this bug: https://sprint.ly/product/1872/#!/item/899

    visit(edit_client_admin_user_path(user, as: client_admin))
    fill_in "Name", :with => ""
    click_button "Save edits"

    fill_in "Name", :with => "Luther Vandross"
    click_button "Save edits"

    expect_content "OK, we've updated this user's information"
    expect_name "Luther Vandross"
  end

  it "should show whether or not the user has joined" do
    user.update_attributes(accepted_invitation_at: nil)
    user.should_not be_claimed
    visit(edit_client_admin_user_path(user, as: client_admin))

    expect_content "Joined: No"
    expect_no_content "Joined: Yes"

    user.update_attributes(accepted_invitation_at: Time.now)
    user.should be_claimed
    visit(edit_client_admin_user_path(user, as: client_admin))

    expect_no_content "Joined: No"
    expect_content "Joined: Yes"
  end

  it "should allow the user to be deleted", js: true do
    visit(edit_client_admin_user_path(user, as: client_admin))
    click_link "Delete user"
    
    should_be_on client_admin_users_path
    expect {user.reload}.to raise_error(ActiveRecord::RecordNotFound)
  end
end
