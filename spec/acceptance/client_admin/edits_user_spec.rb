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

  it "should show whether or not the user has joined" do
    user.update_attributes(accepted_invitation_at: nil)
    user.should_not be_claimed
    visit(edit_client_admin_user_path(user, as: client_admin))

    expect_content "Not joined yet"
    expect_no_content "User has joined!"

    user.update_attributes(accepted_invitation_at: Time.now)
    user.should be_claimed
    visit(edit_client_admin_user_path(user, as: client_admin))

    expect_no_content "Not joined yet"
    expect_content "User has joined!"
  end

  it "should show the user's claim code" do
    user.update_attributes(claim_code: "fmcgillicuddy")
    visit(edit_client_admin_user_path(user, as: client_admin))
    expect_content "Claim code: #{user.claim_code}"
  end

  it "should allow the user to be made an admin" do
    pending "how should the interface for this work?"
  end

  it "should allow the user to be deleted", js: true do
    visit(edit_client_admin_user_path(user, as: client_admin))
    click_link "Delete user"
    
    should_be_on client_admin_users_path
    expect {user.reload}.to raise_error(ActiveRecord::RecordNotFound)
  end
end
