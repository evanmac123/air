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

  def expect_date_of_birth(expected_month, expected_day, expected_year)
    page.find("select#user_date_of_birth_2i").value.should == expected_month
    page.find("select#user_date_of_birth_3i").value.should == expected_day
    page.find("select#user_date_of_birth_1i").value.should == expected_year
  end

  def expect_gender(expected_gender)
    page.find("select#user_gender").value.should == expected_gender
  end

  def expect_employee_id(expected_employee_id)
    page.find("input#user_employee_id").value.should == expected_employee_id
  end

  def expect_zip_code(expected_zip_code)
    page.find("input#user_zip_code").value.should == expected_zip_code
  end

  def expect_role(expected_role)
    page.find('select.user-role-select').value.should == expected_role
  end
  
  def expect_characteristic(characteristic_name, expected_value)
    characteristic = Characteristic.find_by_name(characteristic_name)

    # We pass the datatype through to_s because...
    # > Characteristic::BooleanType === Characteristic::BooleanType
    # false
    #
    # and case uses #===. I'm sure this made sense to someone, once.

    dom_id = "#user_characteristics_#{characteristic.id}"

    case characteristic.datatype.to_s
    when 'Characteristic::BooleanType'
      page.find(dom_id)['checked'].should == expected_value
    when 'Characteristic::DiscreteType'
      page.find(dom_id).find('option[selected=selected]').value.should == expected_value
    else
      page.find(dom_id).value.should == expected_value
    end
  end

  def set_date_of_birth(month, day, year)
    select month, :from => "user_date_of_birth_2i"
    select day,   :from => "user_date_of_birth_3i"
    select year,  :from => "user_date_of_birth_1i"
  end

  def location_select_selector
    '#user_location_id'  
  end

  def location_options_selector
    "#{location_select_selector} option"
  end

  def names_in_select
    page.all(location_options_selector).map(&:text)
  end

  def expect_locations_in_select(locations)
    expected_names = locations.map(&:name)
    (expected_names - names_in_select).should be_empty
  end

  def expect_no_locations_in_select(locations)
    unexpected_names = locations.map(&:name)
    (names_in_select - unexpected_names).should == names_in_select
  end

  it "should update of the same attributes as creation" do
    visit(edit_client_admin_user_path(user, as: client_admin))
    expect_name "Francis X. McGillicuddy"
    expect_email "frank@example.com"
    expect_phone_number "(415) 555-1212"
    expect_date_of_birth "4", "17", "1977"
    expect_gender "male"
    expect_employee_id "12345"
    expect_zip_code "02139"

    fill_in "Name",         :with => "Frances McGillicuddy"
    fill_in "Email",        :with => "fran@example.com"
    fill_in "Phone number", :with => "415-555-1213"
    select  "female",       :from => "Gender"
    fill_in "Employee ID",  :with => "09876"
    fill_in "Zip code",     :with => "94110"
    set_date_of_birth "May", "20", "1975"

    click_button "Save edits"
    expect_name "Frances McGillicuddy"
    expect_email "fran@example.com"
    expect_phone_number "(415) 555-1213"
    expect_date_of_birth "5", "20", "1975"
    expect_gender "female"
    expect_employee_id "09876"
    expect_zip_code "94110"

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
    expect_date_of_birth "4", "17", "1977"
    expect_gender "male"
    expect_employee_id "12345"
    expect_zip_code "02139"

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

  it "should do date of birth partss all-or-none" do
    visit(edit_client_admin_user_path(user, as: client_admin))
    select 'Year', from: "user_date_of_birth_1i"
    click_button "Save edits"

    user.reload.date_of_birth.should == Date.parse("1977-04-17")
    expect_content "Sorry, we weren't able to change that user's information. Please enter a full date of birth"
  end

  context "when changing a user's location" do
    before do
      @other_demo = FactoryGirl.create(:demo)

      @current_demo_locations = FactoryGirl.create_list(:location, 3, demo: client_admin.demo)
      @other_demo_locations =  FactoryGirl.create_list(:location, 3, demo: @other_demo)
    end

    context "of a user in the same board" do
      before do
        @user = FactoryGirl.create(:user, demo: client_admin.demo)
        @user.add_board(@other_demo)
        visit(edit_client_admin_user_path(@user, as: client_admin))
      end

      it "should show locations the board the user and admin are both in" do
        expect_locations_in_select(client_admin.demo.locations)
        expect_no_locations_in_select(@other_demo.locations)
      end

      it "should update the User proper" do
        new_location = @current_demo_locations.first
        select new_location.name, from: 'user_location_id'
        click_button "Save edits"
        @user.reload.location.should == new_location
      end
    end

    context "of a user in a different board" do
      before do
        @user = FactoryGirl.create(:user, demo: @other_demo)
        @user.add_board(client_admin.demo)
        @user.demo.should_not == client_admin.demo
        visit(edit_client_admin_user_path(@user, as: client_admin))
      end

      it "should show locations for board the client admin is in" do
        expect_locations_in_select(client_admin.demo.locations)
        expect_no_locations_in_select(@other_demo.locations)
      end

      it "should update the board membership rather than the user directly" do
        original_location = @other_demo.locations.first
        @user.location = original_location
        @user.save!

        new_location = @current_demo_locations.first
        select new_location.name, from: 'user_location_id'
        click_button "Save edits"
        @user.reload.location.should == original_location
        @user.board_memberships.reload.where(demo_id: client_admin.demo.id).first.location_id.should == new_location.id
      end

      it "should show the user's location in the current board, if any" do
        other_board_location = @other_demo.locations.first
        @user.location = other_board_location
        @user.save!
        
        this_board_location = @current_demo_locations.first
        this_board_membership = @user.board_memberships.find_by_demo_id(client_admin.demo)
        this_board_membership.location_id = this_board_location.id
        this_board_membership.save!

        visit(edit_client_admin_user_path(@user, as: client_admin))
        within(location_select_selector) do
          page.find("option[selected]").text.should == this_board_location.name
        end
      end
    end
  end
end
